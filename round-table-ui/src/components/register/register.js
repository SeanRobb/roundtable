import React, { useState } from 'react';
import PropTypes from 'prop-types';
import queryString from 'query-string';
import styles from './register.module.css';
import { useHistory, useLocation } from "react-router-dom";
import {registerUser, getUsername} from '../../utils/index';
import { Container,Typography, Grid, FormControl, Button, Input, InputLabel } from '@material-ui/core';

function Register(props){
  const location = useLocation();
  let init = queryString.parse(location.search);

  const [gameId, setGameId] = useState(init.game||'');
  const [name, setName] = useState(init.name||getUsername()||'');

  const history = useHistory();

  function handleSubmit() {
    registerUser(gameId.toUpperCase(),name)
      .then(() => {
        history.push('/' + gameId.toUpperCase() + '/board');
      });
  };

  return (
  <Container className={styles.register} data-testid="register" style={{padding:'15px'}}>
    <Grid container>
      <Grid item>
        <Typography variant='h3'>Register for your game:</Typography>
      </Grid>
    </Grid>
    <Grid container direction="column" alignItems='stretch' style={{padding:'15px'}}>
      <Grid item>
        <FormControl fullWidth={true}>
          <InputLabel htmlFor="gameInput">Game:</InputLabel>
            <Input id="gameInput"type="text" value={gameId} onChange={(event) =>{
              setGameId(event.target.value);
            }} name="game" />
        </FormControl>
      </Grid>
      <Grid item>
        <FormControl fullWidth={true}>
          <InputLabel htmlFor="nameInput">Name:</InputLabel>
            <Input id="nameInput" type="text" value={name} onChange={(event) =>{
              setName(event.target.value)
            }}  name="name" />
        </FormControl>
      </Grid>
      <Grid item>
        <Grid container justify='center'>
            <Grid item>
              <Button onClick={handleSubmit}>Submit</Button>
            </Grid>
        </Grid>
      </Grid>
    </Grid>


  </Container>
  );
}

Register.propTypes = {};

Register.defaultProps = {};


export default Register;
