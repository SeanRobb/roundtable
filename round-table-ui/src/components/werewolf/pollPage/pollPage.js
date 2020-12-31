import React from 'react';
import PropTypes from 'prop-types';
import styles from './pollPage.module.css';
import { List, ListItem, Typography, Paper, Grid } from '@material-ui/core';
import Player from '../../player/player';


const PollPage = (props) => (
  <Paper elevation={1} style={props.style}>
    <Typography variant="h5">Poll</Typography>
    <Typography variant="subtitle1">Needs {props.results.needs} total vote{props.results.needs>1?'s':''}</Typography>
    <Grid container direction='column' spacing={2}>
      <Grid item>
        <List>
          {Object.entries(props.results.votes).map((entries) => {
            return (
              <Paper  key={entries[0]} elevation={2}>
                <ListItem key={entries[1].length + entries[0]}>
                  <Grid container alignItems='center'>
                    <Grid item>
                      <Typography style={{paddingRight: '5px'}} variant="body1">{entries[0]} ({entries[1].length}):</Typography>
                    </Grid>
                      {entries[1].map((person)=>
                      <Grid item key={person}>
                          <Player name={person}/>
                      </Grid>
                      )}
                  </Grid>
                </ListItem> 
              </Paper>
            );
          })}
        </List>
      </Grid>
    </Grid>
  </Paper>
);

PollPage.propTypes = {};

PollPage.defaultProps = {};

export default PollPage;
