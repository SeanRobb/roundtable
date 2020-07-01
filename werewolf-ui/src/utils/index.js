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
    .then((res) => res.json())
    .then((data)=>{
      localStorage.setItem('token', data.bearer);
      return data;
    });
};

const vote = (gameId,voteFor) =>{
  const requestOptions = {
    method: 'POST',
    headers: getHeaders(),
    body: JSON.stringify({
      vote:voteFor
    })
  };

  return fetch(process.env.REACT_APP_API_URL+'/gameroom/' + gameId + '/vote',requestOptions)
    .then((res) => res.json());
};

const startGame = (gameId) =>{
  const requestOptions = {
    method: 'POST',
    headers: getHeaders(),
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

const getHeaders = () =>{
  const token = localStorage.getItem("token");
  return token ? { 'Content-Type': 'application/json', "Authorization": "Bearer " + token } : { 'Content-Type': 'application/json' }
};

export { createGameRoom , registerUser, startGame, vote, getHeaders };