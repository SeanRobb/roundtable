const registerUser = (gameId,userId) =>{
  console.log(userId +" " +gameId)
  const requestOptions = {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      username:userId
    })
  };

  return fetch(process.env.REACT_APP_API_URL+'/gameroom/' + gameId + '/register',requestOptions)
    .then((res) => res.json());
};

const startGame = (gameId) =>{
  const requestOptions = {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
  };

  return fetch(process.env.REACT_APP_API_URL+'/gameroom/' + gameId + '/start',requestOptions)
    .then((res) => res.json());
};

const createGameRoom = () => {
  const requestOptions = {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
  };

  return fetch(process.env.REACT_APP_API_URL+ '/gameroom',requestOptions)
    .then((res) => res.json());
};

export { createGameRoom , registerUser, startGame };