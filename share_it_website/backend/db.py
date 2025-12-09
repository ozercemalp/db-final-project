import oracledb
import datetime
from config import Config

class MockDB:
    # Static storage to persist across requests in the same process
    _users = [
        {"USER_ID": 1, "USERNAME": "jdoe", "EMAIL": "jdoe@example.com", "PASSWORD_HASH": "$2b$12$K.X.8.8.8.8.8.8.8.8.8.8.8.8.8.8.8.8.8.8.8.8.8.8.8.8", "KARMA": 10},
        {"USER_ID": 2, "USERNAME": "admin", "EMAIL": "admin@example.com", "PASSWORD_HASH": "hashed_secret", "KARMA": 100}
    ]
    _posts = [
        {"POST_ID": 1, "USER_ID": 1, "USERNAME": "jdoe", "SUBFORUM_ID": 1, "SUBFORUM_NAME": "general", "TITLE": "Hello World", "CONTENT_TEXT": "This is the first post!", "UPVOTES": 5, "CREATED_AT": datetime.datetime.now()},
        {"POST_ID": 2, "USER_ID": 2, "USERNAME": "admin", "SUBFORUM_ID": 2, "SUBFORUM_NAME": "news", "TITLE": "Big News", "CONTENT_TEXT": "Something big happened.", "UPVOTES": 20, "CREATED_AT": datetime.datetime.now()}
    ]
    _subforums = [
            {"SUBFORUM_ID": 1, "NAME": "general", "DESCRIPTION": "General discussion"},
            {"SUBFORUM_ID": 2, "NAME": "news", "DESCRIPTION": "Latest news"}
    ]

    def __init__(self):
        print("Initializing Mock DB")
        # Use the class-level data
        self.users = MockDB._users
        self.posts = MockDB._posts
        self.subforums = MockDB._subforums

    def get_connection(self):
        return self

    def cursor(self):
        return self

    def execute(self, query, params=None):
        print(f"MOCK DB EXECUTE: {query} | Params: {params}")
        self.last_query = query
        self.last_params = params
        return None

    def fetchall(self):
        if "FROM posts" in self.last_query:
            return self.posts
        if "FROM subforums" in self.last_query:
            return self.subforums
        if "FROM users" in self.last_query:
            # Simple mock login logic
            username = self.last_params.get('username')
            for user in self.users:
                if user['USERNAME'] == username:
                    return [user]
            return []
        return []

    def fetchone(self):
        if "FROM users" in self.last_query:
             username = self.last_params.get('username')
             for user in self.users:
                if user['USERNAME'] == username:
                    return user
             return None
        return None

    def callproc(self, name, params):
        print(f"MOCK DB CALLPROC: {name} | Params: {params}")
        if name == 'shareit_pkg.add_user':
             self.users.append({
                 "USER_ID": len(self.users) + 1,
                 "USERNAME": params[0],
                 "EMAIL": params[1],
                 "PASSWORD_HASH": params[2],
                 "KARMA": 0
             })
        elif name == 'shareit_pkg.create_post':
             self.posts.append({
                 "POST_ID": len(self.posts) + 1,
                 "USER_ID": params[0],
                 "USERNAME": "mock_user", # Simplified
                 "SUBFORUM_ID": params[1],
                 "SUBFORUM_NAME": "mock_sub", # Simplified
                 "TITLE": params[2],
                 "CONTENT_TEXT": params[3],
                 "UPVOTES": 0,
                 "CREATED_AT": datetime.datetime.now()
             })
        return params

    def commit(self):
        print("MOCK DB COMMIT")

    def close(self):
        print("MOCK DB CLOSE")

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        pass


def get_db_connection():
    if Config.USE_MOCK_DB:
        return MockDB()

    try:
        connection = oracledb.connect(
            user=Config.ORACLE_USER,
            password=Config.ORACLE_PASSWORD,
            dsn=Config.ORACLE_DSN
        )
        return connection
    except oracledb.Error as e:
        print(f"Error connecting to Oracle DB: {e}")
        return None
