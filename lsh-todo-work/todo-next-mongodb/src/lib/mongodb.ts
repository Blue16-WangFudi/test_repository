import { MongoClient } from "mongodb";

declare global {
  var _mongoClientPromise: Promise<MongoClient> | undefined;
}

const options = {};

function getMongoUri() {
  const uri = process.env.MONGODB_URI;

  if (!uri) {
    throw new Error("Missing MONGODB_URI environment variable");
  }

  return uri;
}

export function getMongoClient() {
  if (process.env.NODE_ENV === "development") {
    if (!global._mongoClientPromise) {
      const client = new MongoClient(getMongoUri(), options);
      global._mongoClientPromise = client.connect();
    }

    return global._mongoClientPromise;
  }

  const client = new MongoClient(getMongoUri(), options);
  return client.connect();
}
