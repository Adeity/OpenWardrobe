FROM dart:stable AS build

# Set working directory inside the container
WORKDIR /app

# Install Flutter manually
RUN git clone https://github.com/flutter/flutter.git -b stable /flutter
ENV PATH="/flutter/bin:$PATH"

# Verify Flutter installation
RUN flutter --version
RUN flutter config --enable-web

ARG SUPABASE_URL
ARG SUPABASE_ANON_KEY

# Copy project files
COPY . .

# Get dependencies
RUN flutter pub get

# Build Flutter Web
RUN flutter build web --release --verbose \
    --web-renderer html \
    --dart-define=SUPABASE_URL=$SUPABASE_URL \
    --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY

# Use Nginx as a lightweight web server
FROM nginx:alpine
# Copy built Flutter Web files to Nginx's HTML directory
COPY --from=build /app/build/web /usr/share/nginx/html

# Expose port 80
EXPOSE 80
# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
