# --- Stage 1: Build ---
FROM dart:stable AS build

WORKDIR /app

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git -b stable /flutter
ENV PATH="/flutter/bin:$PATH"

# Enable Web
RUN flutter config --enable-web

# Copy files and get dependencies
COPY . .
RUN flutter pub get

# Build arguments
ARG SUPABASE_URL
ARG SUPABASE_ANON_KEY

# Build the web app
RUN flutter build web --release \
    --dart-define=SUPABASE_URL=$SUPABASE_URL \
    --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY

# --- Stage 2: Run ---
FROM alpine:latest

# 1. Install the httpd server (from busybox-extras)
RUN apk add --no-cache busybox-extras

# 2. Create a non-root user
RUN adduser -D static
USER static
WORKDIR /home/static

# 3. Create the config file using an ABSOLUTE path
RUN echo "E404:index.html" > /home/static/httpd.conf

# 4. Copy the build files to the html folder
COPY --from=build /app/build/web /home/static/html

# 5. Expose port 3100
EXPOSE 3100

# 6. Start the server using ABSOLUTE paths for everything
# -f: Run in foreground
# -v: Verbose logging (helps debugging)
# -p: Port 3100
# -c: Path to config file (Absolute path fixes your error)
# -h: Path to web files (Absolute path)
CMD ["httpd", "-f", "-v", "-p", "3100", "-c", "/home/static/httpd.conf", "-h", "/home/static/html"]