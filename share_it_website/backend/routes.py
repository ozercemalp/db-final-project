from flask import request, jsonify, session
from app import app
from db import get_db_connection
import bcrypt
import oracledb

# Helper to dictionary-ize rows (since oracledb defaults to tuples)
def dict_factory(cursor, row):
    d = {}
    for idx, col in enumerate(cursor.description):
        d[col[0]] = row[idx]
    return d

@app.route('/api/health', methods=['GET'])
def health_check():
    return jsonify({"status": "ok", "mock_db": app.config['USE_MOCK_DB']})

@app.route('/api/register', methods=['POST'])
def register():
    data = request.json
    username = data.get('username')
    email = data.get('email')
    password = data.get('password')

    if not all([username, email, password]):
        return jsonify({"error": "Missing fields"}), 400

    # Hash password
    hashed = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')

    conn = get_db_connection()
    try:
        cursor = conn.cursor()
        # Call shareit_pkg.add_user
        # Procedure signature: add_user(p_username, p_email, p_password)
        cursor.callproc('shareit_pkg.add_user', [username, email, hashed])
        conn.commit()
        return jsonify({"message": "User registered successfully"}), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        if conn: conn.close()

@app.route('/api/login', methods=['POST'])
def login():
    data = request.json
    username = data.get('username')
    password = data.get('password')

    conn = get_db_connection()
    try:
        cursor = conn.cursor()
        # In real oracledb, we need to set rowfactory to get dicts if we want easier access,
        # but for compatibility with MockDB (which returns dicts) and real DB (which returns tuples by default),
        # let's be explicit.

        # Real DB returns tuples, so we need to map columns.
        # However, MockDB returns list of dicts.

        if app.config['USE_MOCK_DB']:
             query = "SELECT * FROM users WHERE username = :username"
             # MockDB execute expects named params in a dict if configured that way, or list.
             # My MockDB implementation used params dict in execute
             cursor.execute(query, {'username': username})
             user = cursor.fetchone() # MockDB returns dict
        else:
             query = "SELECT user_id, username, password_hash, karma FROM users WHERE username = :username"
             cursor.execute(query, [username]) # Positional or named
             row = cursor.fetchone()
             if row:
                 user = {
                     "USER_ID": row[0],
                     "USERNAME": row[1],
                     "PASSWORD_HASH": row[2],
                     "KARMA": row[3]
                 }
             else:
                 user = None

        if user and bcrypt.checkpw(password.encode('utf-8'), user['PASSWORD_HASH'].encode('utf-8')):
            return jsonify({
                "message": "Login successful",
                "user": {
                    "user_id": user['USER_ID'],
                    "username": user['USERNAME'],
                    "karma": user['KARMA']
                }
            }), 200
        else:
            return jsonify({"error": "Invalid credentials"}), 401
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        if conn: conn.close()

@app.route('/api/posts', methods=['GET'])
def get_posts():
    # Get the optional query parameter
    subforum_name = request.args.get('subforum_name')
    current_user_id = request.args.get('current_user_id')

    conn = get_db_connection()
    try:
        cursor = conn.cursor()
        if app.config['USE_MOCK_DB']:
            # For mock DB, we can just filter in python or ignore (filtering not critical for mock here)
            cursor.execute("SELECT * FROM posts ORDER BY created_at DESC")
            all_posts = cursor.fetchall()
            posts = all_posts
            if subforum_name:
                 # Simple mock filtering if needed, though strictly mock db might not support complex queries
                 # But let's keep it simple and just return all or filter in python for mock
                 pass 
        else:
            # 1. Base Query
            # We need to LEFT JOIN with post_votes to get the user's vote on this post
            # NOTE: We bind current_user_id twice if we use it in the join condition? 
            # Or simpler: LEFT JOIN post_votes pv ON p.post_id = pv.post_id AND pv.user_id = :current_user
            
                
            query = """
                SELECT p.post_id, p.title, p.content_text, p.upvotes, p.created_at,
                       u.username, s.name as subforum_name, p.subforum_id, p.user_id,
                       pv.vote_type as user_vote
                FROM posts p
                JOIN users u ON p.user_id = u.user_id
                JOIN subforums s ON p.subforum_id = s.subforum_id
                LEFT JOIN post_votes pv ON p.post_id = pv.post_id AND pv.user_id = :1
            """
            
            params = []
            # We need to provide current_user_id first for the JOIN
            # Handle case where current_user_id might be None (not logged in) -> use -1 or similar safe value
            safe_user_id = int(current_user_id) if current_user_id else -1
            params.append(safe_user_id)
            
            # 2. Add Filter if subforum_name is provided
            if subforum_name:
                # First check if subforum exists
                check_query = "SELECT COUNT(*) FROM subforums WHERE name = :1"
                cursor.execute(check_query, [subforum_name])
                exists = cursor.fetchone()[0]
                if exists == 0:
                     return jsonify({"error": "Subforum not found"}), 404

                query += " WHERE s.name = :2" # Parameter index 2 because :1 (current_user) is used
                params.append(subforum_name)
            
            # 3. Add Order By
            query += " ORDER BY p.created_at DESC"

            with open("backend_debug.log", "a") as f:
                f.write(f"DEBUG: Executing query with params: {params}\n")
                cursor.execute(query, params)
                
                rows = cursor.fetchall()
                f.write(f"DEBUG: Found {len(rows)} rows\n")
            
            posts = []
            for r in rows:
                content = r[2]
                if isinstance(content, oracledb.LOB):
                    content = content.read()
                
                posts.append({
                    "POST_ID": r[0],
                    "TITLE": r[1],
                    "CONTENT_TEXT": content,
                    "UPVOTES": r[3],
                    "CREATED_AT": r[4],
                    "USERNAME": r[5],
                    "SUBFORUM_NAME": r[6],
                    "SUBFORUM_ID": r[7],
                    "USER_ID": r[8],
                    "USER_VOTE": r[9] # NEW FIELD
                })

        return jsonify(posts), 200
    except Exception as e:
        with open("backend_debug.log", "a") as f:
            f.write(f"ERROR: {str(e)}\n")
            import traceback
            f.write(traceback.format_exc() + "\n")
        return jsonify({"error": str(e)}), 500
    finally:
        if conn: conn.close()

@app.route('/api/posts/<int:post_id>', methods=['GET'])
def get_post_details(post_id):
    current_user_id = request.args.get('current_user_id')
    conn = get_db_connection()
    try:
        cursor = conn.cursor()
        
        # 1. Fetch Post Details
        if app.config['USE_MOCK_DB']:
             # Mock implementation
             cursor.execute("SELECT * FROM posts WHERE post_id = :id", {'id': post_id})
             # ... mock processing ...
             post = {"POST_ID": post_id, "TITLE": "Mock Post", "CONTENT_TEXT": "Mock Content", "UPVOTES": 10, "SUBFORUM_NAME": "MockSub", "USERNAME": "MockUser", "CREATED_AT": "2024-01-01"}
             comments = []
        else:
             query = """
                SELECT p.post_id, p.title, p.content_text, p.upvotes, p.created_at,
                       u.username, s.name as subforum_name, p.subforum_id, p.user_id,
                       pv.vote_type as user_vote
                FROM posts p
                JOIN users u ON p.user_id = u.user_id
                JOIN subforums s ON p.subforum_id = s.subforum_id
                LEFT JOIN post_votes pv ON p.post_id = pv.post_id AND pv.user_id = :1
                WHERE p.post_id = :2
            """
             safe_user_id = int(current_user_id) if current_user_id else -1
             cursor.execute(query, [safe_user_id, post_id])
             row = cursor.fetchone()
             
             if not row:
                 return jsonify({"error": "Post not found"}), 404
             
             content = row[2]
             if isinstance(content, oracledb.LOB):
                 content = content.read()

             post = {
                "POST_ID": row[0],
                "TITLE": row[1],
                "CONTENT_TEXT": content,
                "UPVOTES": row[3],
                "CREATED_AT": row[4],
                "USERNAME": row[5],
                "SUBFORUM_NAME": row[6],
                "SUBFORUM_ID": row[7],
                "USER_ID": row[8],
                "USER_VOTE": row[9]
             }

             # 2. Fetch Comments
             # Assuming comments table: comment_id, post_id, user_id, content_text, created_at
             # And joining with users for username
             comment_query = """
                SELECT c.comment_id, c.content, c.created_at, u.username
                FROM comments c
                JOIN users u ON c.user_id = u.user_id
                WHERE c.post_id = :post_id
                ORDER BY c.created_at ASC
             """
             cursor.execute(comment_query, [post_id])
             comment_rows = cursor.fetchall()
             comments = []
             for cr in comment_rows:
                 c_text = cr[1]
                 if isinstance(c_text, oracledb.LOB):
                     c_text = c_text.read()
                 
                 comments.append({
                     "COMMENT_ID": cr[0],
                     "CONTENT_TEXT": c_text, # Keep key as CONTENT_TEXT for frontend compatibility
                     "CREATED_AT": cr[2],
                     "USERNAME": cr[3]
                 })

        return jsonify({"post": post, "comments": comments}), 200
    except Exception as e:
        with open("backend_debug.log", "a") as f:
            f.write(f"ERROR IN DETAILS: {str(e)}\n")
            import traceback
            f.write(traceback.format_exc() + "\n")
        return jsonify({"error": str(e)}), 500
    finally:
        if conn: conn.close()

@app.route('/api/posts', methods=['POST'])
def create_post():
    data = request.json
    
    user_id = data.get('user_id')
    subforum_id = data.get('subforum_id')
    title = data.get('title')
    content = data.get('content')

    if not all([user_id, subforum_id, title, content]):
        return jsonify({"error": "Missing fields"}), 400

    conn = get_db_connection()
    try:
        cursor = conn.cursor()
        
        # FIX: Use PL/SQL block with Named Notation (=>) to avoid PLS-00307 error.
        # This explicitly tells Oracle we are mapping values to p_user_id (NUMBER), not p_username.
        sql = """
            BEGIN
                shareit_pkg.create_post(
                    p_user_id     => :1,
                    p_subforum_id => :2,
                    p_title       => :3,
                    p_content     => :4
                );
            END;
        """
        
        # Ensure we send integers for the IDs
        cursor.execute(sql, [int(user_id), int(subforum_id), title, content])
        
        conn.commit()
        return jsonify({"message": "Post created"}), 201
    except Exception as e:
        print(f"Error creating post: {e}")
        return jsonify({"error": str(e)}), 500
    finally:
        if conn: conn.close()

@app.route('/api/posts/<int:post_id>/comments', methods=['POST'])
def create_comment(post_id):
    data = request.json
    user_id = data.get('user_id')
    content = data.get('content')
    parent_comment_id = data.get('parent_comment_id') # Optional

    if not all([user_id, content]):
         return jsonify({"error": "Missing fields"}), 400

    conn = get_db_connection()
    try:
        cursor = conn.cursor()
        # Machine overload: create_comment(p_post_id, p_user_id, p_content, p_parent_comment_id)
        # Using named notation for safety with default params
        sql = """
            BEGIN
                shareit_pkg.create_comment(
                    p_post_id           => :1,
                    p_user_id           => :2,
                    p_content           => :3,
                    p_parent_comment_id => :4
                );
            END;
        """
        cursor.execute(sql, [post_id, int(user_id), content, parent_comment_id])
        conn.commit()
        return jsonify({"message": "Comment created"}), 201
    except Exception as e:
        with open("backend_debug.log", "a") as f:
            f.write(f"ERROR COMMENTING: {str(e)}\n")
            import traceback
            f.write(traceback.format_exc() + "\n")
        return jsonify({"error": str(e)}), 500
    finally:
        if conn: conn.close()

@app.route('/api/subforums/<int:subforum_id>/subscribe', methods=['POST'])
def subscribe_subforum(subforum_id):
    data = request.json
    user_id = data.get('user_id')

    if not user_id:
        return jsonify({"error": "Missing user_id"}), 400

    conn = get_db_connection()
    try:
        cursor = conn.cursor()
        # Machine overload: subscribe_user(p_user_id, p_subforum_id)
        cursor.callproc('shareit_pkg.subscribe_user', [int(user_id), subforum_id])
        conn.commit()
        return jsonify({"message": "Subscribed successfully"}), 200
    except Exception as e:
        print(f"Error subscribing: {e}")
        return jsonify({"error": str(e)}), 500
    finally:
        if conn: conn.close()

@app.route('/api/subforums', methods=['GET'])
def get_subforums():
    conn = get_db_connection()
    try:
        cursor = conn.cursor()
        if app.config['USE_MOCK_DB']:
            cursor.execute("SELECT * FROM subforums")
            subs = cursor.fetchall()
        else:
            cursor.execute("SELECT subforum_id, name, description FROM subforums")
            rows = cursor.fetchall()
            subs = []
            for r in rows:
                subs.append({
                    "SUBFORUM_ID": r[0],
                    "NAME": r[1],
                    "DESCRIPTION": r[2]
                })
        return jsonify(subs), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        if conn: conn.close()

@app.route('/api/posts/<int:post_id>/vote', methods=['POST'])
def vote_post(post_id):
    data = request.json
    user_id = data.get('user_id')
    vote_type = data.get('vote_type') # 1, -1, or 0

    if user_id is None or vote_type is None:
        return jsonify({"error": "Missing fields"}), 400

    conn = get_db_connection()
    try:
        cursor = conn.cursor()
        # Machine overload: vote_post(p_user_id, p_post_id, p_vote_type)
        cursor.callproc('shareit_pkg.vote_post', [user_id, post_id, vote_type])
        conn.commit()
        return jsonify({"message": "Vote cast"}), 200
    except Exception as e:
        with open("backend_debug.log", "a") as f:
            f.write(f"ERROR: {str(e)}\n")
            import traceback
            f.write(traceback.format_exc() + "\n")
        return jsonify({"error": str(e)}), 500
    finally:
        if conn: conn.close()
