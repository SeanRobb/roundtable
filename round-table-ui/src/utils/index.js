import jwt from 'jwt-decode';
import { config } from './constants'

const enableNotifications =() =>{
  if (!('Notification' in window)) {
    console.log("This browser does not support notifications.");
  } else {
    try {
      Notification.requestPermission();
    } catch(e) {
      console.log("This browser does not support notifications.");
    }
  }
}

function checkNotificationPromise() {
  try {
    Notification.requestPermission().then();
  } catch(e) {
    return false;
  }

  return true;
}

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
const deleteOption = (gameId, optionid) => {
  const requestOptions = {
    method: 'DELETE',
    headers: getHeaders()
  };
  return fetch(config.url.API_URL+'/gameroom/' + gameId + '/next-round/option/'+optionid,requestOptions)
    .then((res) => res.json());
};

const getPlayersForBet=(roster,bet) => {
  let test = roster.map((player)=> player.betsPlaced.map((playerBet) => {
    if(playerBet.id == bet.id){
      return {"name":player.name,"selection":playerBet.selection};
    }
  }).filter(x => x !== undefined)).filter((x)=> x.length != 0);
  return test.flat(1);
}

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
  enableNotifications,
  checkNotificationPromise,
  createGameRoom,
  registerUser,
  startGame,
  vote,
  createBet,
  selectBet,
  closeBet,
  freezeBet,
  createOption,
  deleteOption,
  getPlayersForBet, 
  getHeaders,
  getUsername,
  clearUsername,
  changeTimeOfDay,
  isUserRegistered
 };