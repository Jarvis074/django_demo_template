FROM python:latest

COPY . .

RUN pip install -r requirements.txt

CMD ["python", "-m", "uvicorn", "django_demo_site.asgi:application", "--host", "0.0.0.0", "--port", "80"]