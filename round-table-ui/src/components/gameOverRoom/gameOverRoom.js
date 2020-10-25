import React from 'react';
import PropTypes from 'prop-types';
import styles from './gameOverRoom.module.css';
import {Container, Paper, Typography, Grid } from '@material-ui/core';  
import CreateGameButton from '../createGameButton/createGameButton';

const GameOverRoom = (props) => (
  <Container className={styles.gameOverRoom} data-testid="GameOverRoom">
    <Paper elevation={1}>
      <Grid container direction="column" alignItems="center" justify="center">
        <Grid item>
          <Typography align='center' variant='h3'>{props.game.villageWins?"Village Wins":"Werewolves Win"}</Typography>
        </Grid>
        <Grid item>
          <Typography align='center' variant='h5'>Want to start a new game?</Typography>
        </Grid>
        <Grid item>
          <CreateGameButton />
        </Grid>
      </Grid>
    </Paper>
  </Container>
);

GameOverRoom.propTypes = {};

GameOverRoom.defaultProps = {};

export default GameOverRoom;
