FROM python:3.8.6

WORKDIR /app

ADD . /app
RUN pip install -r requirements.txt
RUN python setup.py install
CMD ["python", "-m", "p3back"]
