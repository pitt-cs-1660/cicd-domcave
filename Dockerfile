FROM python:3.11-buster AS builder

WORKDIR /app

# 3. install poetry and upgrade pip
RUN pip install --upgrade pip && pip install poetry

# 4. build application using peotry
#   - copy pyproject.toml and poetry.lock files
#   - then build
COPY cc_compose cc_compose
COPY nginx nginx
COPY static static
COPY pyproject.toml poetry.lock ./

RUN poetry config virtualenvs.create false \
&& poetry install --no-root --no-interaction --no-ansi

FROM python:3.11-buster AS app

WORKDIR /app

# 5. Copy code from builder /app dir into app /app dir
COPY --from=builder /app/ /app/

# Copy installed dependencies from builder stage
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# 6. Expose port 8000
EXPOSE 8000

# 7. Set entrypoint.sh as entrypoint for container
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x ./entrypoint.sh
ENTRYPOINT [ "/app/entrypoint.sh" ]

# 8. Set CMD parameter to run application
CMD [ "uvicorn", "cc_compose.server:app", "--reload", "--host", "0.0.0.0", "--port", "8000" ]



