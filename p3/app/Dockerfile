FROM golang:alpine AS build
ARG APP_VERSION=v1
WORKDIR /src
COPY go.mod main.go ./
RUN CGO_ENABLED=0 go build -ldflags "-s -w -X main.version=${APP_VERSION}" -o /app

FROM scratch
COPY --from=build /app /app
EXPOSE 8888
ENTRYPOINT ["/app"]