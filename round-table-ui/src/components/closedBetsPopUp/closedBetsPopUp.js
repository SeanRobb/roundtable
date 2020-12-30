import React from 'react';
import PropTypes from 'prop-types';
import styles from './closedBetsPopUp.module.css';
import { Grid, Box, Dialog, DialogTitle,  } from '@material-ui/core';
import BetView from '../betView/betView';

const ClosedBetsPopUp = (props) => {
  const getPlayersForBet=(roster,bet) => {
    let test = roster.map((player)=> player.betsPlaced.map((playerBet) => {
      if(playerBet.id == bet.id){
        return {"name":player.name,"selection":playerBet.selection};
      }
    }).filter(x => x !== undefined)).filter((x)=> x.length != 0);
    return test.flat(1);
  }
  return (
    <Dialog ref={props.inputRef} className={styles.closedBetsPopUp} data-testid="closedBetsPopUp"
      open={props.open}
      fullWidth={true}
      onClose={props.onClose}
    >
      <Box className='popup\_inner'>  
        <DialogTitle>
          Closed Bets
        </DialogTitle>
        <Grid container 
          direction="column"
          alignItems="center"
          justify="center">
          <Grid item>
            <Grid container
                direction='column'
                spacing={2}>
              {props.bets
              .filter((bet) => bet.state == "CLOSED")
              .map((bet)=> {
                let players = getPlayersForBet(props.roster,bet);
                return (
                  <Grid item 
                  key={bet.id}>
                    <BetView bet={bet} role={props.role} players={players}></BetView>
                  </Grid>
                );
              }
              )}
            </Grid>
          </Grid>
        </Grid>
      </Box>  
    </Dialog>
)};

ClosedBetsPopUp.propTypes = {};

ClosedBetsPopUp.defaultProps = {};

export default ClosedBetsPopUp;
