FROM python:3.11-alpine AS builder

COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

FROM python:3.11-alpine

ARG LAB_LOGIN
ARG LAB_TOKEN

LABEL org.lab.login=$LAB_LOGIN \
      org.lab.token=$LAB_TOKEN

RUN addgroup -S appuser && adduser -S appuser -G appuser

WORKDIR /app

COPY --from=builder /root/.local /home/appuser/.local
COPY --chown=appuser:appuser app/ ./

ENV PATH="/home/appuser/.local/bin:$PATH" \
    ROCKET_SIZE="Small" \
    LAB_LOGIN=$LAB_LOGIN \
    LAB_TOKEN=$LAB_TOKEN

USER appuser

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8000/health || exit 1

CMD ["python", "app.py"]