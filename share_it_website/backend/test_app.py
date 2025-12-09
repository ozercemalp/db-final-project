import unittest
import json
from app import app
from db import get_db_connection

class BackendTestCase(unittest.TestCase):
    def setUp(self):
        # Configure app for testing
        app.config['TESTING'] = True
        app.config['USE_MOCK_DB'] = True # Force mock DB for tests
        self.app = app.test_client()

    def test_health(self):
        response = self.app.get('/api/health')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json['mock_db'], True)

    def test_get_posts(self):
        response = self.app.get('/api/posts')
        self.assertEqual(response.status_code, 200)
        data = response.json
        self.assertTrue(isinstance(data, list))
        self.assertTrue(len(data) > 0)
        self.assertIn('TITLE', data[0])

    def test_get_subforums(self):
        response = self.app.get('/api/subforums')
        self.assertEqual(response.status_code, 200)
        data = response.json
        self.assertTrue(len(data) > 0)
        self.assertEqual(data[0]['NAME'], 'general')

    def test_register_login_flow(self):
        # Register
        user_data = {
            "username": "testuser",
            "email": "test@example.com",
            "password": "password123"
        }
        res_reg = self.app.post('/api/register',
                                data=json.dumps(user_data),
                                content_type='application/json')
        self.assertEqual(res_reg.status_code, 201)

        # Login
        login_data = {
            "username": "testuser",
            "password": "password123"
        }
        res_login = self.app.post('/api/login',
                                  data=json.dumps(login_data),
                                  content_type='application/json')
        self.assertEqual(res_login.status_code, 200)
        self.assertEqual(res_login.json['user']['username'], 'testuser')

    def test_create_post(self):
        post_data = {
            "user_id": 1,
            "subforum_id": 1,
            "title": "Test Post",
            "content": "Test Content"
        }
        res = self.app.post('/api/posts',
                            data=json.dumps(post_data),
                            content_type='application/json')
        self.assertEqual(res.status_code, 201)

if __name__ == '__main__':
    unittest.main()
