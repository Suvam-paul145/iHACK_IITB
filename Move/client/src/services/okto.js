import axios from 'axios';

const baseUrl = process.env.NEXT_PUBLIC_BASE_URL
const clientApiKey = process.env.NEXT_PUBLIC_CLIENT_ID
const authToken = process.env.NEXT_PUBLIC_CLIENT_SECRET;

export const getPortfolio = async () => {
  try {
    const response = await axios.get(`${baseUrl}/api/v1/portfolio`, {
      headers: {
        'x-api-key': clientApiKey,
        'Authorization': `Bearer ${authToken}`,
        'accept': 'application/json',
      }
    });
    console.log(response.data); 
    return response.data;
  } catch (error) {
    console.error('Request failed:', error);
    throw error; 
  }
};

// Usage example:
getPortfolio().then(data => {
  console.log('Portfolio data:', data);
}).catch(error => {
  console.error('Error fetching portfolio data:', error);
});


export const authenticate = async () => {
  try {
    const response = await axios.post(
      `${baseUrl}/api/v1/authenticate`,
      {
        id_token: idToken
      },
      {
        headers: {
          'accept': '*/*',
          'x-api-key': clientApiKey,
          'Content-Type': 'application/json'
        }
      }
    );

    console.log(response.data); // Handle the response data here
    return response.data;
  } catch (error) {
    console.error('Request failed:', error);
    throw error; // Handle the error here
  }
};


authenticate().then(data => {
  console.log('Authentication successful:', data);
}).catch(error => {
  console.error('Error during authentication:', error);
});