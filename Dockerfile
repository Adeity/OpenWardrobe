# --- Stage 1: Build (Same as before) ---
FROM dart:stable AS build
WORKDIR /app
RUN git clone https://github.com/flutter/flutter.git -b stable /flutter
ENV PATH="/flutter/bin:$PATH"
RUN flutter config --enable-web
COPY . .
RUN flutter pub get

ARG SUPABASE_URL
ARG SUPABASE_ANON_KEY

RUN flutter build web --release \
    --dart-define=SUPABASE_URL=$SUPABASE_URL \
    --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY

# --- Stage 2: Run (The Magic Part) ---
FROM alpine:latest

# Create a user to run securely (optional but good practice)
RUN adduser -D static
USER static
WORKDIR /home/static

# Copy built files
COPY --from=build /app/build/web ./html

# Expose port 3000
EXPOSE 3100

# Run Alpine's built-in HTTP server
# -f: Don't detach (run in foreground)
# -v: Verbose (show logs)
# -p: Port
# -h: Home directory for files
CMD ["httpd", "-f", "-v", "-p", "3000", "-h", "/home/static/html"]