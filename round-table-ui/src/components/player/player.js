import React from 'react';
import PropTypes from 'prop-types';
import styles from './player.module.css';
import { Grid, Container, Typography } from '@material-ui/core';
import PersonIcon from '@material-ui/icons/Person';
import LocalLibraryIcon from '@material-ui/icons/LocalLibrary';

const Player = (props) => (
  <Container>
    <Grid container direction={props.direction} justify='center' alignItems='center'>
      <Grid item>
        {props.isNarrator?<LocalLibraryIcon/>:<PersonIcon />}
      </Grid>
      <Grid item>
        <Typography variant='subtitle1'>{props.name}</Typography>
      </Grid>
    </Grid>
  </Container>
);

Player.propTypes = {};

Player.defaultProps = {
  direction:'column',
  isNarrator:false,
  name:'',
};

export default Player;
