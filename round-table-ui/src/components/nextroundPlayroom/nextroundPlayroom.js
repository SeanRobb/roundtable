import React, { useState } from 'react';
import { useHistory } from "react-router-dom";
import * as R from 'ramda';
import styles from './nextroundPlayroom.module.css';
import Player from '../player/player';
import { Typography, Grid, Paper, Container, Button, Fab,Link }  from '@material-ui/core';
import Leaderboard from '../leaderboard/leaderboard';
import BetList from '../betList/betList';

import ClosedBetsPopUp from '../closedBetsPopUp/closedBetsPopUp';
import AddBetPopUp from '../addBetPopUp/addBetPopUp';
import AddOptionPopUp from '../addOptionPopUp/addOptionPopUp';

import PersonAddIcon from '@material-ui/icons/PersonAdd';
import LinkIcon from '@material-ui/icons/Link';
import History from '@material-ui/icons/History';
import Add from '@material-ui/icons/Add';
import BetBreakdownPopup from '../betBreakdownPopup/betBreakdownPopup';

import {getPlayersForBet} from '../../utils/index'


const NextRoundPlayroom = (props) => {
  const currentHistory = useHistory();
  const [state, setState] = useState({
    showClosedBetsPopUp: false,
    showAddOptionPopUp:false,
    showAddBetPopUp:false,
    showBetBreakdownPopUp:false,
  });

  const [option, setOption] = useState({
    id:"",
    title:"",
    description:"",
    choiceA:"",
    choiceB:"",
    link:"",
  });

  const [bet, setBet] = useState({
    id:"",
    title:"",
    description:"",
    choiceA:"",
    choiceB:"",
    link:"",
  });

  function toggleClosedBetsPopup() {  
    setState({
      ...state,
      showClosedBetsPopUp: !state.showClosedBetsPopUp, 
    });  
  }; 

  function toggleBetBreakdownPopup(bet) {
    if (bet!== undefined){
      console.log(bet);
      setBet(bet);
    } else{
      setBet({
        id:"",
        title:"",
        description:"",
        choiceA:"",
        choiceB:"",
        link:"",
      })
    }
    setState({
      ...state,
      showBetBreakdownPopUp: !state.showBetBreakdownPopUp, 
    });  
  }

  function toggleAddOptionsPopup() {  
    setState({
      ...state,
      showAddOptionPopUp: !state.showAddOptionPopUp, 
    });  
    setOption({
      id:"",
      title:"",
      description:"",
      choiceA:"",
      choiceB:"",
      link:"",
    })
  }; 

  function toggleAddBetPopup() {  
    setState({
      ...state,
      showAddBetPopUp: !state.showAddBetPopUp, 
    });  
  }; 

  function editOptionClick(option) {
    setOption({
      id:option.id,
      title:option.title,
      description:option.description,
      choiceA:option.choiceA,
      choiceB:option.choiceB,
      link:option.link,
    })
    console.log(option);
    setState({
      ...state,
      showAddOptionPopUp:true,
    })

  }

  return (
  <div className={styles.nextroundPlayroom} data-testid="nextroundPlayroom">
    <Grid container spacing={3}
      style={{padding:'24px'}} 
      direction="row"
      justify="space-evenly"
      alignItems="stretch">
        <Grid item xs={12} sm={4} md={2} >
          <Paper style={{height:'100%'}} elevation={1}>
            <Container style={{height:'100%', paddingLeft:'20px', paddingRight:'20px'}}>
                <Grid container
                  alignItems="center"
                  justify="center"
                  style={{height:'100%'}}>
                  <Grid item>
                    <Grid container spacing={2} 
                      direction="column"
                      alignItems="center"
                      justify="space-evenly"
                      >
                      <Grid item>
                        <Typography variant="h5">Captain:</Typography>
                      </Grid>
                      <Grid item>
                        <Player isNarrator={true} name={props.state.game.roster.find((player)=>player.isCaptain).name} />
                      </Grid>
                      <Grid item>
                        <Typography variant='body2'>Roomcode:</Typography>
                      </Grid>
                        <Grid item>
                          <Link  href={window.location.href}>
                            <Grid container
                              justify='center'
                              alignItems='center'
                              spacing={1}
                            >
                          <Grid item>
                            <Typography variant='body2'>{props.state.game.id}</Typography>
                          </Grid>
                          <Grid item>
                            <LinkIcon/>
                          </Grid>
                        </Grid>
                        </Link>
                      </Grid>
                      <Grid item>
                      {R.isEmpty(props.state.role)?
                        <Button onClick={()=>{
                          currentHistory.push('/register?game='+ props.state.game.id)
                        }}>Register?</Button>:<div/>}
                      </Grid>
                      <Grid item>
                      </Grid>
                    </Grid> 
                  </Grid>
                </Grid>
              </Container>
          </Paper>
        </Grid>
        <Grid item xs={12} sm={8} md={10}>
          <Leaderboard leaderboard={props.state.leaderboard} />
        </Grid>
        <Grid item xs={12}>
          <BetList gameId={props.state.game.id} role={props.state.role} bets={props.state.game.bets} roster={props.state.game.roster} toggleBetBreakdown={toggleBetBreakdownPopup}/>
        </Grid>
    </Grid>
    <div style={{height:120}} />

    <ClosedBetsPopUp 
      open={state.showClosedBetsPopUp}
      roster={props.state.game.roster}
      bets={props.state.game.bets}
      role={props.state.role}
      toggleBetBreakdown={toggleBetBreakdownPopup}
      onClose={toggleClosedBetsPopup}
    />

    <BetBreakdownPopup 
      open={state.showBetBreakdownPopUp}
      players={getPlayersForBet(props.state.game.roster,bet)}
      bet={bet}
      onClose={()=>toggleBetBreakdownPopup()}
    />
    <AddBetPopUp 
      open={state.showAddBetPopUp}
      options={props.state.game.options}
      gameId={props.state.game.id}
      editOption={editOptionClick}
      onClose={toggleAddBetPopup}
    />

    <AddOptionPopUp 
      open={state.showAddOptionPopUp}
      gameId={props.state.game.id}
      title={option.title}
      description={option.description}
      choiceA={option.choiceA}
      choiceB={option.choiceB}
      link={option.link}
      onClose={toggleAddOptionsPopup}
    />

    {/* Bottom Icons */}
    <Grid container spacing={2} direction='row-reverse' justify='space-between' alignItems='flex-end' style={{position: 'fixed', bottom: '7px'}}>
      {R.isEmpty(props.state.role)?
        <Grid item>
          <Fab variant="extended" onClick={()=>{
            currentHistory.push('/register?game='+ props.state.game.id)
          }} ><><PersonAddIcon/> Register</></Fab>    
        </Grid>:
          <>
            <Grid item>
              <Fab variant="extended" onClick={toggleClosedBetsPopup}><History />{props.state.role.player.name}</Fab>    
            </Grid>
            <Grid item>
              <Grid container
                spacing={1}
                direction="column"
                >
                <Grid item>
                  {props.state.role.name === 'Captain'?
                      <Fab variant="extended" onClick={toggleAddBetPopup}><><Add/>Bet</></Fab>
                      :<div/>
                      }
                </Grid>
                <Grid item>
                  <Fab variant="extended" onClick={toggleAddOptionsPopup}><><Add/>Option</></Fab>
                </Grid>
              </Grid>
            </Grid>

          </>  
      }
    </Grid>
  </div>);
};

NextRoundPlayroom.propTypes = {};

NextRoundPlayroom.defaultProps = {};

export default NextRoundPlayroom;
