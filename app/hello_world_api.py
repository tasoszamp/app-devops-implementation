from fastapi import FastAPI

app = FastAPI(debug=False)

@app.get("/goodmorning")
async def root():
    return "Goodmorning World"

@app.get("/goodnight")
async def root():
    return "Goodnight World"