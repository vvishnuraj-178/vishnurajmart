# Deploy VishnuRajMart on Koyeb with Neon PostgreSQL

This repository contains a C++17/Drogon web application and an HTML frontend. The root-level Dockerfile builds the executable and packages it with vishnurajmart.html.

## Free-tier expectations

Koyeb's Free Instance currently provides 512 MB RAM, 0.1 vCPU, and 2 GB SSD. Only one Free Instance is allowed per organization; free instances are available in Frankfurt or Washington, D.C. and scale to zero after one hour without traffic. It is suitable for a demo or low-traffic test, not a production availability guarantee.

Official references:
- [Koyeb GitHub deployment](https://www.koyeb.com/docs/build-and-deploy/deploy-with-git)
- [Koyeb instance types and Free Instance limits](https://www.koyeb.com/docs/reference/instances)
- [Koyeb exposed ports and PORT](https://www.koyeb.com/docs/build-and-deploy/exposing-your-service)

## 1. Check Neon PostgreSQL

1. Open [Neon Console](https://console.neon.tech/) and choose the database this application should use.
2. Copy its PostgreSQL connection string. Prefer Neon's pooled connection string for the web application and retain SSL mode (usually sslmode=require).
3. Never put a database URL, password, Brevo API key, Twilio token, or Gemini key in GitHub source code.
4. The application uses PostgreSQL crypt() and gen_salt(); the pgcrypto extension is needed.

### Schema: choose the safe path

- For a **new or empty database**, open schema.sql in this repository and run it in that database's Neon SQL Editor.
- If the existing Neon database already contains users/products/orders or important data, **do not run this schema blindly**. CREATE TABLE IF NOT EXISTS does not migrate an existing table with incompatible columns. First inspect and back up the schema/data, then reconcile it with the current main.cc queries.

A quick inspection query for the Neon SQL Editor:

~~~sql
SELECT table_name, column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN ('users', 'products', 'cart_items', 'orders', 'order_items', 'product_reviews')
ORDER BY table_name, ordinal_position;
~~~

The current backend expects, among other fields, users.mobile, users.password_hash, users.is_verified, users.otp_hash, users.otp_expires_at, users.otp_attempts, and products.seller_id. The backend is not a database migration tool.

## 2. Deploy the GitHub repository on Koyeb

1. Open [Koyeb](https://app.koyeb.com/) and sign in.
2. Choose **Create Web Service** and select **GitHub** as the deployment source.
3. If prompted, install Koyeb's GitHub App and grant it access to vvishnuraj-178/vishnurajmart.
4. Select repository vvishnuraj-178/vishnurajmart, branch main.
5. Choose **Dockerfile** as the Builder and set the Dockerfile location to Dockerfile (repository root).
6. Name the App/Service vishnurajmart.
7. Choose the **Free** instance. For this tier, choose **Frankfurt** or **Washington, D.C.** if those are the region choices Koyeb shows.
8. Under **Exposed ports**, configure port 8080, protocol **HTTP**, public access enabled, and route /. The C++ program listens on 0.0.0.0 and reads PORT; Koyeb sets PORT based on the exposed port.
9. Add the environment variables below. Use Koyeb's Secret type for private keys and connection strings.
10. Click **Deploy**. Open the build logs first, then deployment/runtime logs if the build succeeds but the service fails to start.

The Dockerfile copies VishnuRajMart and vishnurajmart.html to the same /app working directory because Drogon serves the HTML file from that directory.

## 3. Add Koyeb environment variables

### Required for the Neon database

| Name | Value |
| --- | --- |
| VISHNURAJMART_DATABASE_URL | Full Neon PostgreSQL connection string, including SSL mode |

Do **not** set VISHNURAJMART_DB_PASSWORD for cloud deployment. That fallback is configured for a local PostgreSQL server at 127.0.0.1, not Neon.

### Required for email OTP registration

| Name | Value |
| --- | --- |
| VISHNURAJMART_EMAIL | Your verified sender email address in Brevo |
| VISHNURAJMART_BREVO_API_KEY | Your Brevo API key |

Email OTP will not work until Brevo sender verification and account/API configuration are complete.

### Optional integrations

| Name | Needed for |
| --- | --- |
| TWILIO_ACCOUNT_SID | Twilio login-alert SMS |
| TWILIO_AUTH_TOKEN | Twilio login-alert SMS |
| TWILIO_FROM_NUMBER | Twilio sender number |
| VISHNURAJMART_GEMINI_API_KEY | AI help chat |

Only set optional integrations that you have configured. Keep all keys private.

## 4. Verify the deployment

Once Koyeb reports the deployment as healthy:

1. Open the public .koyeb.app URL.
2. Register a test buyer and confirm the email OTP arrives.
3. Log in, then test product loading, seller product creation, cart, checkout, and buyer/seller orders.
4. Check Koyeb runtime logs and Neon query/connection status if any API fails.

## Troubleshooting

- **Build fails on CMake/Drogon:** read the first compilation error in Koyeb's build logs. The Dockerfile installs Drogon and required C++/PostgreSQL/libcurl development packages in the build stage.
- **Deployment is unhealthy / site cannot connect:** confirm that port 8080 is publicly exposed over HTTP and the app binds to 0.0.0.0.
- **relation does not exist or column does not exist:** the Neon schema does not match the code. Inspect the table/column query above; do not delete data to silence the error.
- **Registration saves but no OTP arrives:** verify both Brevo variables, approved sender address, and email delivery status in Brevo.
- **First page load is slow after inactivity:** this is expected on the Koyeb Free Instance, which scales to zero after one hour without traffic.

A successful GitHub upload does not prove a successful Koyeb build. Confirm the build, health status, and core flows on the actual deployed URL.
