# 🎤 Backstage DevConf.cz Workshop

Welcome to the **Backstage DevConf.cz 2025 Lab**!  
In this hands-on workshop, you'll go from zero to a fully functional Backstage developer portal — installed, configured, and running locally on your machine. No prior Backstage experience required!

---

## 🚀 Step 1: Getting Set Up

Before we dive in, make sure you have the following tools installed:

- [Git](https://git-scm.com/downloads)
- [Node.js (v18+)](https://nodejs.org/en/download/)
- [Yarn](https://classic.yarnpkg.com/en/docs/install/)
- [Docker](https://www.docker.com/products/docker-desktop/)

To confirm you're good to go, run:


```bash
node -v
yarn -v
git --version
docker --version
```

## 🏗️ Step 2: Create a New Backstage App

Run the following command to create your app:

```bash
npx @backstage/create-app
```

When prompted, enter the name of your app:

```bash
? Enter a name for the app [required] → backstage-devconf-lab
```

Once it’s finished scaffolding, move into the app directory:

```bash
cd backstage-devconf-lab/
```

## 🌍 Step 3: Push to GitHub

Now let’s get your app into a GitHub repository:

1. Navigate to [GitHub](https://github.com/) and click `New repository`.

2. Name it: `backstage-devconf-lab` (same as your app folder)

3. ❗️Important: Do not add a README — your app already has one!

4. Click Create Repository

You should see the following viewport:
![create-new-repository](./images/new-repo-github.png)

Then return to your terminal and run:

```bash
git init
git branch -M main
git add .
git commit -s -m "Initial commit"
git remote add origin https://github.com/<your-username>/backstage-devconf-lab.git
git push -u origin main
```

💡 Replace <your-username> with your actual GitHub username.
You should now see your project live on GitHub!

## 🔍 Step 4: Run the App Locally

Start the development server:

```bash
yarn start
```

You should see the following viewport:

![backstage-catalog](./images/my-company-catalog.png)

🎉 That’s it! You’re now running a fresh Backstage developer portal locally.

Next up: We’ll customize your app name and start configuring GitHub Authentication 🎸!

---

## 🎨 Step 5: Customize App Name

Open the `app-config.yaml` file in the root of your project (yep, same level as your `package.json`):

Look for the following section:

```yaml
app:
  title: My Company Catalog

organization:
  name: My Company
```

Change it to something that represents your vibe. For example:

```yaml
app:
  title: Rockit Engine

organization:
  name: Rockit Rockets
```
💡 This updates the name shown in the header of your Backstage UI.

The default `.gitignore` file created with the app excludes `*.local.yaml` from source control for you, so you can add passwords or tokens directly into the `app-config.local.yaml`.

Restart Backstage from the terminal, by stopping it with `Control-C`, and starting it with `yarn start` to see the changes. The default Backstage Catalog screen will look like this:

![rockit-rockets-catalog](./images/rockit-rockets.png)

 🎉 Well Done! Your App Has a Name — Now Let’s  set up **GitHub Authentication** so you can log in securely 🔐

---

## 🔑 Step 6: Setting Up GitHub Authentication

Backstage supports a bunch of auth providers, but for this workshop, we’ll use GitHub — it’s fast, familiar, and perfect for devs.

### 🧭 Add a new app to GitHub
Go to https://github.com/settings/applications/new to create your OAuth App.

Homepage URL should point to Backstage's frontend, in our tutorial it would be `http://localhost:3000`
Authorization callback URL should point to the auth backend, `http://localhost:7007/api/auth/github/handler/frame`

You should see the following viewport:
![register-oauth-app](./images/register-oauth-app.png)

Click `Register application` to generate a new `Client Secret` and take a note of the `Client ID` and the `Client Secret`.

### 🧭 Add the credentials to the configuration
Open `app-config.local.yaml` add the below configuration and replace the values with the `Client ID` and the `Client Secret` from GitHub.

```yaml
auth:
  environment: development
  providers:
    github:
      development:
        clientId: YOUR CLIENT ID
        clientSecret: YOUR CLIENT SECRET
```
❗️Remember to update your OAuth App on GitHub after you have generated your `Client secret`.

### 🧭 Add sign-in option to the frontend
This step is needed to change the sign-in page. Get ready to dive into the code.

1. Open `packages/app/src/App.tsx` in your favorite code editor and add:

    ```bash
    import { githubAuthApiRef } from '@backstage/core-plugin-api';
    import { SignInProviderConfig, SignInPage } from '@backstage/core-components';

    const githubProvider: SignInProviderConfig = {
    id: 'github-auth-provider',
    title: 'GitHub',
    message: 'Sign in using GitHub',
    apiRef: githubAuthApiRef,
    };
    ```
    💡 You may notice that the  `'@backstage/core-components'` package is already imported, feel free to adjust the imported components as needed.

2. Search for `const app = createApp({` in this file, and below `apis,`, find `components` and update it to this:

    ```bash
    components: {
        SignInPage: props => (
            <SignInPage
                {...props}
                auto
                provider={githubProvider}
            />
        ),
    },
    ```

3. To add the provider to the backend we will first need to install the package by running this command, from your Backstage root directory:

   ```bash
   yarn --cwd packages/backend add @backstage/plugin-auth-backend-module-github-provider
   ```

4. Then in `packages/backend/src/index.ts` find this line:

   ```bash
   backend.add(import('@backstage/plugin-auth-backend'));
   ```

    and add the following line right underneath:

    ```bash
    backend.add(import('@backstage/plugin-auth-backend-module-github-provider'));
    ```

Restart Backstage from the terminal, by stopping it with `Control-C`, and starting it with `yarn start` . You should be welcomed by a login prompt. For example:

![github-log-in](./images/github-log-in.png)

Click `SIGN IN`

You should see a popup asking to authorize your OAuth App, Click `Authorize`!

References: <https://backstage.io>
