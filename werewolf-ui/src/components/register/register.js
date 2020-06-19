import React, { useState } from 'react';
import PropTypes from 'prop-types';
import queryString from 'query-string';
import styles from './register.module.css';
import { useHistory, useLocation } from "react-router-dom";
import {registerUser} from '../../utils/index';

function Register(props){
  const location = useLocation();
  let init = queryString.parse(location.search);

  const [gameId, setGameId] = useState(init.game);
  const [name, setName] = useState(init.name);

  const history = useHistory();

  function handleSubmit(event) {
    event.preventDefault();
    registerUser(name,gameId)
    .then(() => {
      history.push('/' + gameId + '/board');
    });
  };

  return (
  <div className={styles.register} data-testid="register">
    <h2>Please register for your game</h2>
    <form onSubmit={handleSubmit.bind(this)} >
      <label>
        Game:
        <input type="text" value={gameId} onChange={(event) =>{
          setGameId(event.target.value);
        }} name="game" />
      </label>
      <label>
        Name:
        <input type="text" value={name} onChange={(event) =>{
          setName(event.target.value)
        }}  name="name" />
      </label>
      <input type="submit" value="Submit"/>
    </form>
  </div>
  );
}

Register.propTypes = {};

Register.defaultProps = {};


export default Register;
