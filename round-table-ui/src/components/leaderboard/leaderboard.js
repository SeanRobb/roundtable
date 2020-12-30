import React from 'react';
import styles from './leaderboard.module.css';
import { Typography, Grid, Paper } from '@material-ui/core';

const Leaderboard = (props) => {
  const getVariant = (index) => {
    if (index === 0 ) {
      return 'h4';
    }
    return 'h6'
  }
  const getPlayer = (player, index) =>{
    return (
      <Grid item key={player.name}>
        <Typography align='left' variant={getVariant(index)}>{index+1}: {player.name} - {player.points}</Typography>
      </Grid>
    );
  }
  return (
  <div className={styles.leaderboard} data-testid="Leaderboard">
    <Paper style={{height:'100%', padding:'5px'}} elevation={1}>
      <Grid container
        direction="column"
        alignItems="center"
        justify="space-evenly"
                >
          <Grid item>
            <Typography variant="h2">Leaderboard:</Typography>
          </Grid>
          <Grid item>
            <Grid container
            direction='column'
            alignItems='flex-start'>
              {props.leaderboard
                .map((player, index)=>
                getPlayer(player,index)
              )}
            </Grid>
          </Grid>

      </Grid>
    </Paper>
  </div>
)};

Leaderboard.propTypes = {};

Leaderboard.defaultProps = {};

export default Leaderboard;
