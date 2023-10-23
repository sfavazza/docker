FROM golang:1.21.0

RUN go install golang.org/x/tools/gopls@v0.12.4

# required by dap-mode
RUN go install github.com/go-delve/delve/cmd/dlv@latest

WORKDIR /code
