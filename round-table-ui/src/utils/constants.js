const prod = {
  url: {
   API_URL: 'https://api.roundtable.hoodie.work',
  }
 };

const dev = {
  url: {
   API_URL: 'http://localhost:9292'
  }
 };
 export const config = process.env.NODE_ENV === 'development' ? dev : prod;