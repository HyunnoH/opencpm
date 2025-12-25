import express from "express";
import dotenv from "dotenv";
import path from "node:path";
import { existsSync } from "node:fs";

dotenv.config({
  path: "../../.env",
});

async function main() {
  const app = express();
  const port = Number(process.env.PORT) || 3000;
  const uiRoot = process.env.UI_DIST_PATH;

  if (uiRoot && existsSync(uiRoot)) {
    app.use(express.static(uiRoot));
    app.get("*", (_req, res) => {
      res.sendFile(path.join(uiRoot, "index.html"));
    });
  }

  app.listen(port, () => {
    console.log(`Server is running on port ${port}`);
  });
}

main();
