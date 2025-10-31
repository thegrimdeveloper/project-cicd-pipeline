# Use the official Python image
FROM python:3.10-slim

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy the requirements file and install packages
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application code into the container
COPY ./app .

# Set environment variable for the port
ENV PORT=8080

# Expose the port
EXPOSE 8080

# The command to run the application
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "main:app"]