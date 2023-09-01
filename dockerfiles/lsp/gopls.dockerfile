FROM golang:1.21.0

RUN go install golang.org/x/tools/gopls@latest
