from playwright.sync_api import sync_playwright

def verify_home_sidebar():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()

        print("Navigating to Home...")
        page.goto("http://localhost:5173", timeout=60000)

        print("Waiting for Sidebar...")
        # Check for TOP COMMUNITIES text
        try:
            page.wait_for_selector("text=TOP COMMUNITIES", timeout=10000)
            print("Sidebar found.")
        except:
            print("Sidebar NOT found (Timeout).")

        page.screenshot(path="/home/jules/verification/10_home_sidebar_retry.png")
        print("Screenshot saved.")

        browser.close()

if __name__ == "__main__":
    verify_home_sidebar()
