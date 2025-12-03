from fastapi import FastAPI, Depends
from sqlalchemy.orm import Session
from database import SessionLocal, engine , Base
from models import User

Base.metadata.create_all(bind=engine)

app = FastAPI(title="Innovatech HR App")

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.get("/")
def root():
    return {"status": "HRAPI is running"}

@app.post("/users")
def create_user(firstname: str, lastname:str, email: str, db: Session = Depends(get_db)):
    user = User(firstname=firstname, lastname=lastname, email=email)
    db.add(user)
    db.commit()
    db.refresh(user)
    return user

@app.get("/users")
def get_users(db: Session = Depends(get_db)):
    return db.query(User).all()

@app.delete("/users/{user_id}")
def delete_user(user_id: int, db: Session = Depends(get_db)):
    user =db.query(User).filter(User.id == user_id).first()
    if not user:
        return {"error": "User not found"}
    
    db.delete(user)
    db.commit()

    return {"message": "User deleted"}
