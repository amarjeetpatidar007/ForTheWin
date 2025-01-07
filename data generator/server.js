const { DataAPIClient,InsertManyError } = require('@datastax/astra-db-ts');
const { faker } = require('@faker-js/faker'); 
const express = require('express');
require('dotenv').config();

const app = express();

const client = new DataAPIClient(process.env.ASTRA_DB_APPLICATION_TOKEN); 
const db = client.db(process.env.ASTRA_DB_ENDPOINT);
const COLLECTION_NAME = 'social_data'; 

const generateRandomPostData = (postIndex) => {
  return {
    post_id: `p${1001 + postIndex}`,
    post_type: faker.helpers.arrayElement(['reel', 'story', 'carousel','story']),
    content: faker.lorem.sentence(),
    timestamp: faker.date.future().toISOString().split('T')[0], 
    platform: faker.helpers.arrayElement(['instagram', 'facebook', 'twitter']),
    likes: faker.number.int({ min: 1000, max: 10000 }).toString(),
    comments: faker.number.int({ min: 50, max: 500 }).toString(),
    shares: faker.number.int({ min: 50, max: 500 }).toString(),
    views: faker.number.int({ min: 1000, max: 10000 }).toString(),
    "audience_18-24": faker.number.int({ min: 10, max: 50 }).toString(),
    "audience_25-34": faker.number.int({ min: 20, max: 50 }).toString(),
    "audience_35-44": faker.number.int({ min: 10, max: 40 }).toString(),
    "audience_45": faker.number.int({ min: 5, max: 30 }).toString()
  };
};

(async function () {
  try {
    const posts = Array.from({ length: 10 }, (_, index) => generateRandomPostData(index));

    const result = await db.collection(COLLECTION_NAME).insertMany(posts);
    console.log(`Inserted ${posts.length} posts:`, result);
    
  } catch (e) {
    if (e instanceof InsertManyError) {
      console.log('Partial insert result:', e.partialResult);
    } else {
      console.error('Error:', e);
    }
  }
})();



(async () => {
  try {
    const collections = await db.listCollections();
    console.log('Connected to AstraDB. Collections:', collections);
    
    app.listen(3001, () => {
      console.log('Server is running on port 3001');
    });

  } catch (error) {
    console.error('Error connecting to Astra DB:', error);
  }
})();
