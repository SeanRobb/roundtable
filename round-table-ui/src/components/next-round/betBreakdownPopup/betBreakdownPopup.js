import React from 'react';
import PropTypes from 'prop-types';
import styles from './betBreakdownPopup.module.css';
import { Box, Dialog, DialogTitle, Typography, Grid, DialogContentText, IconButton, Paper } from '@material-ui/core';
import LaunchIcon from '@material-ui/icons/Launch';
import Grade from '@material-ui/icons/Grade';
import Player from '../../player/player';

const BetBreakdownPopup = (props) => {
  const playersThatSelected = (selection) => {
    return props.players.filter((player) => player.selection == selection).map((player)=> player.name)
  }

  const renderSide =(choice)  => {
    return (
      <Paper elevation={2} 
      style={{height:'100%'}}>
        <Grid container
          direction='column'
          alignItems='stretch'
          spacing={0}
          >
          <Grid item>
              <Grid container
                justify='center'
                alignItems='center'>

                <Grid item xs={2} sm={1}> 
                  {choice === props.bet.correctChoice?<Grade/>:<div/>}
                </Grid>
                <Grid item xs={8} sm={10}>
                  <Typography align='center'>{choice}</Typography>
                </Grid>
                <Grid item xs={2} sm={1}>
                  <Grid container
                    justify='flex-end'>
                      <Grid item>
                      </Grid>
                  </Grid>
                </Grid>
              </Grid>
          </Grid>
          <Grid item>
            <Grid container
              direction='column'
              justify='center'
              alignItems='stretch'
              >
              {
                playersThatSelected(choice)
                .map((player)=>{
                  return (
                    <Grid item key={player}>
                        <Player name={player}/>
                    </Grid>
                  );
                })
              }
            </Grid>
          </Grid>
        </Grid>
      </Paper>

    );
  }

  return (
    <Dialog className={styles.BetBreakdownPopup} data-testid="betBreakdownPopup"
      open={props.open}
      onClose={props.onClose}
    >
      <Box className='popup\_inner'>  
        <DialogTitle align='center'>
          {props.bet.title}
        </DialogTitle>
        <DialogContentText align='center'>
          {props.bet.description}
        </DialogContentText>
        <Grid container
          direction='column'
          justify='center'
          alignItems='stretch'>
          <Grid item>
              <Grid container
                direction='row'
                justify='center'
                alignItems='stretch'
                >
              {/* Column for Choice A */}
              <Grid item xs={6} sm={6} md={6} lg={6} xl={6}>
                  {renderSide(props.bet.choiceA)}
              </Grid>
              {/* Column for Choice B */}
              <Grid item xs={6} sm={6} md={6} lg={6} xl={6}>
                  {renderSide(props.bet.choiceB)}
              </Grid>
            </Grid>
          </Grid>
          <Grid item>
            <Grid container
              alignItems='flex-end'
              justify='flex-end'>
              <Grid item >
                <IconButton 
                  disabled={props.bet.link === ""}
                  onClick={()=>{
                    var win = window.open(props.bet.link, '_blank');
                    win.focus();
                  }}
                ><LaunchIcon/></IconButton>
              </Grid>
            </Grid>
          </Grid>
        </Grid>
      </Box>  
    </Dialog>
)};

BetBreakdownPopup.propTypes = {};

BetBreakdownPopup.defaultProps = {};

export default BetBreakdownPopup;
