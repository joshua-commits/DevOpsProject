from hello import app


def test_root_endpoint():
    client = app.test_client()
    response = client.get("/")
    data = response.get_json()  

    assert response.status_code == 200
    assert  data["message"] == "Hello, World!"
    assert "timestamp" in data
    assert data["status"] == "OK"