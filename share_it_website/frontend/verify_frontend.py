from playwright.sync_api import sync_playwright

def verify_app():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()

        # 1. Visit Home Page
        print("Navigating to Home...")
        page.goto("http://localhost:5173")
        page.wait_for_load_state("networkidle")
        page.screenshot(path="/home/jules/verification/01_home.png")
        print("Screenshot 01_home.png saved.")

        # 2. Visit Register Page
        print("Navigating to Register...")
        page.goto("http://localhost:5173/register")
        page.wait_for_selector("input[type='text']")
        page.fill("input[type='text']", "newuser")
        page.fill("input[type='email']", "new@example.com")
        page.fill("input[type='password']", "password")
        page.screenshot(path="/home/jules/verification/02_register.png")
        print("Screenshot 02_register.png saved.")

        # Click Sign Up
        page.click("button:has-text('Sign Up')")
        page.wait_for_url("**/login")

        # 3. Login
        print("Navigating to Login...")
        page.fill("input[type='text']", "newuser")
        page.fill("input[type='password']", "password")
        page.screenshot(path="/home/jules/verification/03_login.png")
        print("Screenshot 03_login.png saved.")

        page.click("button:has-text('Sign In')")
        page.wait_for_url("http://localhost:5173/")

        # 4. Verify Logged In State on Home
        page.wait_for_selector("text=u/newuser")
        page.screenshot(path="/home/jules/verification/04_logged_in.png")
        print("Screenshot 04_logged_in.png saved.")

        # 5. Create Post
        print("Navigating to Create Post...")
        page.click("text=+ Create")
        page.wait_for_url("**/create-post")
        page.fill("input[placeholder='Title']", "Playwright Test Post")
        page.fill("textarea", "Content from playwright")
        page.screenshot(path="/home/jules/verification/05_create_post.png")
        print("Screenshot 05_create_post.png saved.")

        page.click("button:has-text('Post')")
        page.wait_for_url("http://localhost:5173/")

        # 6. Verify New Post
        page.wait_for_selector("text=Playwright Test Post")
        page.screenshot(path="/home/jules/verification/06_post_created.png")
        print("Screenshot 06_post_created.png saved.")

        browser.close()

if __name__ == "__main__":
    verify_app()
