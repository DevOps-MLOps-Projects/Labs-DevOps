#####################################
#                                   #
#  @author      : 00xWolf           #
#    GitHub    : @mmsaeed509       #
#    Developer : Mahmoud Mohamed   #
#  﫥  Copyright : Mahmoud Mohamed   #
#                                   #
#####################################

# Use an official, minimized Python base image #
FROM python:3.11-slim

# Set the working directory in the container #
WORKDIR /app

# Copy requirements.txt first to leverage Docker build cache #
COPY app/requirements.txt .

# Install any needed packages specified in requirements.txt #
RUN pip install -r requirements.txt

# Copy the application code #
COPY app/app.py .

# Make port 5000 available to the world outside this container #
EXPOSE 5000

# Run app.py when the container launches #
CMD ["python", "app.py"]
