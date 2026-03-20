# CONTRIBUTING.md

## 1. Environment Setup

1. **Fork the repository** on GitHub to create your own copy.
2. **Clone your fork** to your local machine:
   ```sh
   git clone https://github.com/<your-username>/unison-social-media-app.git
   cd unison-social-media-app
   ```
3. **Configure Upstream Remote** to keep your fork synced with the main repository:
   ```sh
   git remote add upstream https://github.com/nexus/unison-social-media-app.git
   ```
4. **Initialize Environment**: Create a `.env` file in the root directory.
   ```sh
   touch .env
   ```
   *Note: Populate this with the necessary credentials (e.g., Supabase URL/Anon Key).*
5. **Install Flutter Dependencies**:
   ```sh
   flutter pub get
   ```
6. **IDE Setup**: Open the project in **Android Studio**. Ensure the Flutter and Dart plugins are active and pointing to your local SDK path.

---

## 2. Development Workflow

#### Branching
Create a feature-specific branch to isolate your changes. Do not work directly on the `main` branch.
```sh
git checkout -b feat/your-feature-name
```

### Syncing
To avoid merge conflicts, pull the latest changes from the original repository regularly.
```sh
git fetch upstream
git rebase upstream/main
```

---

## 3. Submitting Changes

1. **Stage and Commit**: Use clear, literal commit messages describing the technical change.
   ```sh
   git add .
   git commit -m "feat: implement video feed pagination"
   ```
2. **Push to Fork**:
   ```sh
   git push origin feat/your-feature-name
   ```
3. **Open a Pull Request**:
   * Navigate to the original repository on GitHub.
   * Select **Compare & pull request**.
   * Provide a technical summary of the changes and link any relevant issues.

---

## 4. Post-Merge Cleanup

Once your Pull Request has been merged into the main repository, delete your local and remote feature branches to keep the environment clean.

1. **Switch to main**:
   ```sh
   git checkout main
   ```
2. **Update local main**:
   ```sh
   git pull upstream main
   ```
3. **Delete local branch**:
   ```sh
   git branch -d feat/your-feature-name
   ```
4. **Delete remote branch**:
   ```sh
   git push origin --delete feat/your-feature-name
   ```
