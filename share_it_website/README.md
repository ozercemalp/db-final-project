# ShareIt Website (Frontend + Backend)

This project provides a modern React frontend and a Python Flask backend for the ShareIt database project.

## Project Structure

*   `website/backend/`: Python Flask API
*   `website/frontend/`: React Vite Application

## Prerequisites

*   Python 3.8+
*   Node.js 14+ and npm
*   Oracle Database (local or remote) with the ShareIt schema installed (see `../our_project/run_all.sql`).

## Setup

### 1. Database Setup

Ensure your Oracle database is running and the ShareIt schema is deployed.
Update the backend configuration with your database credentials.

### 2. Backend Setup

1.  Navigate to `website/backend`:
    ```bash
    cd website/backend
    ```
2.  Install dependencies:
    ```bash
    pip install -r requirements.txt
    ```
3.  Configure Environment Variables:
    *   Open `config.py` and verify defaults, OR set the following environment variables:
        *   `ORACLE_USER`: Your DB username (default: system)
        *   `ORACLE_PASSWORD`: Your DB password (default: oracle)
        *   `ORACLE_DSN`: Your DB DSN (default: localhost:1521/xe)
        *   `USE_MOCK_DB`: Set to `False` to use the real database. (Default is `True` for testing without DB).
        *   `SECRET_KEY`: Random string for sessions.

    *Example (Linux/Mac):*
    ```bash
    export USE_MOCK_DB=False
    export ORACLE_USER=myuser
    export ORACLE_PASSWORD=mypassword
    ```

4.  Run the Backend:
    ```bash
    python3 app.py
    ```
    The server will start on `http://127.0.0.1:5000`.

### 3. Frontend Setup

1.  Navigate to `website/frontend`:
    ```bash
    cd website/frontend
    ```
2.  Install dependencies:
    ```bash
    npm install
    ```
3.  Run the Development Server:
    ```bash
    npm run dev
    ```
    The site will be available at `http://localhost:5173`.

## Features

*   **Authentication:** Register and Log In (Password hashing via Bcrypt).
*   **Feed:** View posts from all subforums.
*   **Create Post:** Select a subforum and create a new post.
*   **Voting:** Upvote/Downvote posts.
*   **Mock Mode:** The application runs in Mock Mode by default (`USE_MOCK_DB=True`), allowing you to test the UI logic without an active Oracle connection. Switch this to `False` to connect to the real database.

## Notes for Developer

*   The backend uses `oracledb` to connect to Oracle.
*   It utilizes the PL/SQL package `shareit_pkg` for data manipulation (registration, posting, voting).
*   The frontend proxies `/api` requests to `localhost:5000` via `vite.config.js`.
