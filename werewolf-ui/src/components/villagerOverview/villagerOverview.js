import React from 'react';
import PropTypes from 'prop-types';
import styles from './villagerOverview.module.css';
import { Typography, Avatar, Paper, Grid } from '@material-ui/core';
import Player from '../player/player';

const VillagerOverview = (props) => (
  <Paper elevation={1} style={props.style}>
    <Grid container spacing={2} 
      alignItems="center"
      style={{height:'100%', paddingLeft:'24px', paddingRight:'24px'}}>
      <Grid item>
        <Typography variant="h5">Village:</Typography>
      </Grid>
      <Grid item>
        <Grid container spacing={2} justify='space-evenly' alignItems='center'>
          {props.roster
            .filter((player)=>player.isActive==true)
            .map((player)=>
            <Grid item key={player.name}>
              <Player name={player.name}/>
            </Grid>
          )}
        </Grid>
      </Grid>
    </Grid>
  </Paper>
);

VillagerOverview.propTypes = {};

VillagerOverview.defaultProps = {};

export default VillagerOverview;
