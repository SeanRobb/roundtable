import jwt from 'jwt-decode';

const getURL=() =>{
  return process.env.REACT_APP_API_URL;
}

const registerUser = (gameId,userId) =>{
  const requestOptions = {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      username:userId
    })
  };

  return fetch(getURL()+'/gameroom/' + gameId + '/register',requestOptions)
    .then((res) => res.json())
    .then((data)=>{
      localStorage.setItem('token', data.bearer);
      return data;
    });
};

const changeTimeOfDay = (gameId,timeOfDay) =>{
  const requestOptions = {
    method: 'POST',
    headers: getHeaders()
  };

  return fetch(getURL()+'/gameroom/' + gameId + '/' + timeOfDay,requestOptions)
    .then((res) => res.json());
};

const vote = (gameId,voteFor) =>{
  const requestOptions = {
    method: 'POST',
    headers: getHeaders(),
    body: JSON.stringify({
      vote:voteFor
    })
  };

  return fetch(getURL()+'/gameroom/' + gameId + '/vote',requestOptions)
    .then((res) => res.json());
};

const startGame = (gameId) =>{
  const requestOptions = {
    method: 'POST',
    headers: getHeaders(),
  };

  return fetch(getURL()+'/gameroom/' + gameId + '/start',requestOptions)
    .then((res) => res.json());
};

const createGameRoom = () => {
  const requestOptions = {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
  };

  return fetch(getURL()+ '/gameroom',requestOptions)
    .then((res) => res.json());
};

const getHeaders = () =>{
  const token = localStorage.getItem("token");
  return token ? { 'Content-Type': 'application/json', "Authorization": "Bearer " + token } : { 'Content-Type': 'application/json' }
};

const getUsername= () =>{
  const decodedToken = localStorage.getItem("token");
  if(decodedToken){
    return jwt(decodedToken)['username'];
  }
  return '';
}

const clearUsername= () =>{
  localStorage.clear();
  return '';
}

export { createGameRoom , registerUser, startGame, vote, getHeaders, getUsername, clearUsername, changeTimeOfDay };