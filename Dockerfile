FROM python:latest

COPY . .

RUN pip install -r requirements.txt

CMD ["uvicorn", "--port", "80", "--host", "0.0.0.0", "django_demo_site.asgi:application"]