import jwt from 'jwt-decode';
import { config } from './constants'

const registerUser = (gameId,userId) =>{
  const requestOptions = {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      username:userId
    })
  };

  return fetch(config.url.API_URL+'/gameroom/' + gameId + '/register',requestOptions)
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

  return fetch(config.url.API_URL+'/gameroom/' + gameId + '/werewolf/' + timeOfDay,requestOptions)
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

  return fetch(config.url.API_URL+'/gameroom/' + gameId + '/werewolf/vote',requestOptions)
    .then((res) => res.json());
};

const createBet = (gameId, option) => {
  const requestOptions = {
    method: 'POST',
    headers: getHeaders(),
    body: JSON.stringify(option)
  };

  return fetch(config.url.API_URL+'/gameroom/' + gameId + '/next-round/bet',requestOptions)
    .then((res) => res.json());
};

const freezeBet = (gameId, betId) => {
  const requestOptions = {
    method: 'PUT',
    headers: getHeaders(),
    body: JSON.stringify({state:"freeze"})
  };

  return fetch(config.url.API_URL+'/gameroom/' + gameId + '/next-round/bet/'+betId+'/state',requestOptions)
    .then((res) => res.json());
};

const closeBet = (gameId, betId, selection) => {
  const requestOptions = {
    method: 'PUT',
    headers: getHeaders(),
    body: JSON.stringify({state:"close",selection})
  };
  return fetch(config.url.API_URL+'/gameroom/' + gameId + '/next-round/bet/'+betId+'/state',requestOptions)
    .then((res) => res.json());
};

const selectBet = (gameId,betId, selection) => {
  const requestOptions = {
    method: 'PUT',
    headers: getHeaders(),
    body: JSON.stringify({selection})
  };
  return fetch(config.url.API_URL+'/gameroom/' + gameId +'/next-round/bet/'+betId+ '/selection',requestOptions)
    .then((res) => res.json());
};

const createOption = (gameId, option) => {
  const requestOptions = {
    method: 'POST',
    headers: getHeaders(),
    body: JSON.stringify(option)
  };
  return fetch(config.url.API_URL+'/gameroom/' + gameId + '/next-round/option',requestOptions)
    .then((res) => res.json());
};

const startGame = (gameId) =>{
  const requestOptions = {
    method: 'POST',
    headers: getHeaders(),
  };

  return fetch(config.url.API_URL+'/gameroom/' + gameId + '/start',requestOptions)
    .then((res) => res.json());
};

const createGameRoom = (type) => {
  const requestOptions = {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({type})
  };

  return fetch(config.url.API_URL+ '/gameroom',requestOptions)
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

const isUserRegistered = () => {
  const decodedToken = localStorage.getItem("token");
  if(decodedToken){
    return true;
  }
  return false;
}

export { 
  createGameRoom,
  registerUser,
  startGame,
  vote,
  createBet,
  selectBet,
  closeBet,
  freezeBet,
  createOption,
  getHeaders,
  getUsername,
  clearUsername,
  changeTimeOfDay,
  isUserRegistered
 };