import React from 'react';
import PropTypes from 'prop-types';
import styles from './leaderboard.module.css';
import { Typography, Grid, Paper, Container } from '@material-ui/core';
import Player from '../player/player';

const Leaderboard = (props) => (
  <div className={styles.leaderboard} data-testid="Leaderboard">
    <Paper style={{height:'100%', padding:'5px'}} elevation={1}>
      <Grid container spacing={2} 
                direction="column"
                alignItems="center"
                justify="space-evenly"
                >
          <Grid item>
            <Typography variant="h3">Leaderboard:</Typography>
            {props.leaderboard
              .map((player, index)=>
              <Grid item key={player.name}>
                <Typography variant={index==0?"h4":"h6"}>{index+1}: {player.name} - {player.points}</Typography>
              </Grid>
            )}
          </Grid>
      </Grid>
    </Paper>
  </div>
);

Leaderboard.propTypes = {};

Leaderboard.defaultProps = {};

export default Leaderboard;
