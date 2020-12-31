import React from 'react';
import PropTypes from 'prop-types';
import styles from './waitingRoom.module.css';
import { useHistory } from "react-router-dom";
import Player from '../../player/player';
import {startGame} from '../../../utils/index';
import Button from '@material-ui/core/Button';  
import { Container, Grid, Typography, Paper } from '@material-ui/core';

const WaitingRoom = (props) => {
  const history = useHistory();
  function start(event) {
    event.preventDefault();
    startGame(props.state.id);
  };

return (
  <Container style={{paddingTop:'10px'}} className={styles.WaitingRoom} data-testid="WaitingRoom">
    <Paper elevation={1} style={{paddingTop:'10px'}}>
      <Grid container direction='column' spacing={3}>
        <Grid item>
          <Paper elevation={2}>
            <Grid container justify='space-around' alignItems='center'>
              <Grid item>
                <Typography variant='h3'>Waitingroom</Typography>
              </Grid>
              <Grid item>
                <Grid container direction='column' alignItems='center'>
                  <Grid item>
                    <Typography variant='h5'>Type: {props.state.type}</Typography>
                    <Typography variant='h5'>Roomcode: {props.state.id}</Typography>
                  </Grid>
                  <Grid item>
                    <Button onClick={()=>{
                      history.push('/register?game='+ props.state.id)
                    }}>Register?</Button>
                  </Grid>
                </Grid>
              </Grid>
            </Grid>
          </Paper>
        </Grid>
        <Grid item>
          <Paper elevation={2} style={{padding:'15px'}}>
            <Typography variant='h5'>Players in room:</Typography>
            <Grid container>
              {props.state.roster.map((player) => {
                return ( <Grid item key={player.name}>
                  <Player name={player.name} isNarrator={player.isNarrator||player.isCaptain}></Player>
                </Grid>
                );
              })}
            </Grid>
          </Paper>
        </Grid>
        <Grid item>
          <Paper elevation={2}>
            <Grid container direction='column' justify='center' alignItems='center'>
              <Grid item>
                <Typography variant='h6'> {props.waitingroom.canStart?"Ready to play?":props.waitingroom.description}</Typography>
              </Grid>
              <Grid item>
                <Button variant="outlined" onClick={start} disabled={!props.waitingroom.canStart}>
                  Start Game
                </Button>
              </Grid>
            </Grid>
          </Paper>
        </Grid>
      </Grid>
    </Paper>
  </Container>
)};

WaitingRoom.propTypes = {};

WaitingRoom.defaultProps = {};

export default WaitingRoom;
