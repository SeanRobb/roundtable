import React from 'react';
import styles from './betList.module.css';
import { Typography, Grid, Paper, Container } from '@material-ui/core';
import BetView from '../betView/betView';

const BetList = (props) => {
  const renderBets = (state) => {
    return props.bets
      .filter((bet) => bet.state == state)
      .map((bet)=> {
        let players = getPlayersForBet(props.roster,bet);
        return (
          <Grid item 
          key={bet.id}>
            <BetView 
              gameId={props.gameId} 
              bet={bet} 
              players={players} 
              role={props.role}
            />
          </Grid>
        );
      })
  }
  const getPlayersForBet=(roster,bet) => {
    let test = roster.map((player)=> player.betsPlaced.map((playerBet) => {
      if(playerBet.id == bet.id){
        return {"name":player.name,"selection":playerBet.selection};
      }
    }).filter(x => x !== undefined)).filter((x)=> x.length != 0);
    return test.flat(1);
  }
  return (
  <div className={styles.betList} data-testid="betList">
    <Paper style={{height:'100%', padding:'5px'}} elevation={1}>
      <Grid container
                direction="column"
                alignItems="stretch"
                justify="center"
                >
        <Grid item xs={12}>
        <Grid container 
          alignItems="center"
          justify="center">
            <Grid item>
              <Typography variant="h3">Bets:</Typography>
            </Grid>
          </Grid>
        </Grid>
        <Grid item xs={12}>
          <Grid container
            spacing={2}
            direction="row"
            alignItems="stretch"
            justify="space-around"
                    >
            <Grid item xs={12} sm={6} md={6} lg={6}>
              <Grid container 
                direction="column"
                alignItems="stretch"
                spacing={2}
                justify="center">
                <Grid item xs={12}>
                  <Grid container 
                  alignItems="center"
                  justify="center">
                    <Grid item>
                      <Typography variant="h6">Open:</Typography>
                    </Grid>
                  </Grid>
                </Grid>
                <Grid item xs={12}>
                  <Grid container
                    direction='column'
                    spacing={2}>
                    {renderBets("OPEN")}
                  </Grid>
                </Grid>
              </Grid>
            </Grid>
            <Grid item xs={12} sm={6} md={6} lg={6}>
              <Grid container 
                      direction="column" 
                      alignItems="stretch"
                      spacing={2}
                      justify="center">
                <Grid item>
                  <Grid container 
                    alignItems="center"
                    justify="center">
                      <Grid item>
                        <Typography variant="h6">Frozen:</Typography>
                      </Grid>
                  </Grid>
                </Grid>
                <Grid item>
                <Grid container
                    direction='column'
                    spacing={2}>
                  {renderBets("FROZEN")}
                  </Grid>
                </Grid>
              </Grid>
            </Grid>
          </Grid>
        </Grid>
      </Grid>
    </Paper>
  </div>
)};

BetList.propTypes = {};

BetList.defaultProps = {};

export default BetList;
