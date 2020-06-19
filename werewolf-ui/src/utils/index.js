const registerUser = (gameId,userId) =>{
  const requestOptions = {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: {
      username:userId
    }
  };

  return fetch('https://trs2utmz46.execute-api.us-east-1.amazonaws.com/dev/gameroom/' + gameId + '/register',requestOptions)
    .then((res) => res.json());
};

const createGameRoom = () => {
  const requestOptions = {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
  };

  return fetch('https://trs2utmz46.execute-api.us-east-1.amazonaws.com/dev/gameroom',requestOptions)
    .then((res) => res.json());
};

export { createGameRoom , registerUser };