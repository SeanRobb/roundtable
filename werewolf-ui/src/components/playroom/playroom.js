import React, { useState }  from 'react';
import PropTypes from 'prop-types';
import styles from './playroom.module.css';
import RolePopup from '../rolePopup/rolePopup';
import VotePopup from '../votePopup/votePopup';
import DeactivatedPopup from '../deactivatedPopup/deactivatedPopup';
import PollPage from '../pollPage/pollPage';
import Player from '../player/player';
import VillagerOverview from '../villagerOverview/villagerOverview';
import Fab from '@material-ui/core/Fab';  
import HowToVoteIcon from '@material-ui/icons/HowToVote';
import PersonIcon from '@material-ui/icons/Person';
import {vote, changeTimeOfDay} from '../../utils/index';
import { Typography, Box, Avatar, Card, Grid, Paper, Container } from '@material-ui/core';
import Brightness3Icon from '@material-ui/icons/Brightness3';
import Brightness7Icon from '@material-ui/icons/Brightness7';


const Playroom = (props) => {
  //TODO updates to props.state do not propagate
  const [state, setState] = useState({showRolePopUp:false, showVotePopUp:false, showDeactivatedPopup:false});
  const [deactivatedPlayer, setDeactivatedPlayer] = useState();

  function toggleRolePopup() {  
    setState({
      ...state,
      showRolePopUp: !state.showRolePopUp, 
    });  
  };  

  function submitVote(player) {  
    setState({
      ...state,
      showVotePopUp: false, 
    });  
    vote(props.state.game.id, player);
  }; 

  function submitTimeOfDayChange() {  
    console.log("Change Time of Day");
    setState({
      ...state,
      showDeactivatedPopup: true
    });  
    let changeTo = props.state.game.location.isNight?'day':'night';
    changeTimeOfDay(props.state.game.id,changeTo)
    .then((data)=>{
      setDeactivatedPlayer(data.deactivatedPlayer);
      toggleDeactivatedPopup();
    });

  }; 

  function toggleVotePopup() {  
    setState({
      ...state,
      showVotePopUp: !state.showVotePopUp, 
    });  
  }; 

  function toggleDeactivatedPopup() {  
    setState({
      ...state,
      showDeactivatedPopup: !state.showDeactivatedPopup   
    });  
  }; 

  return (
  <div className={styles.Playroom} data-testid="Playroom">
    <Grid container spacing={3}
      style={{padding:'24px'}} 
      direction="row"
      justify="space-evenly"
      alignItems="stretch">
 
    {/* Roster Breakdown Start */}
      <Grid item>
        <Paper style={{height:'100%', padding:'5px'}} elevation={1}>
          <Grid container spacing={2} 
            direction="column"
            alignItems="center"
            justify="center"
            style={{height:'100%', paddingLeft:'24px', paddingRight:'24px'}}>
            <Grid item>
              <Typography variant="h5">Narrator:</Typography>
            </Grid>
            <Grid item>
              <Player isNarrator={true} name={props.state.game.roster.find((player)=>player.isNarrator).name} />
            </Grid>
          </Grid> 
        </Paper>
      </Grid>
      <Grid item>
        <Paper elevation={1} style={{height:'100%', padding:'5px'}}>
        <Container>
            <Grid container 
              direction="column"
              justify="center"
              spacing={2}>
              <Grid item>
                  {props.state.game.location.isNight?
                    <Brightness3Icon style={{ fontSize: 100 }} />:
                    <Brightness7Icon style={{ fontSize: 100 }}/>}
              </Grid>
              <Grid item>
                  <Grid container direction='column'>
                    <Grid item>
                      <Typography variant="body2" style={{padding:'5px'}}>Day: {props.state.game.location.day}</Typography>
                    </Grid>
                    <Grid item>
                      <Typography variant="body2" style={{padding:'5px'}}>Population: {props.state.game.roster.filter((player)=>player.isActive==true).length}</Typography>
                    </Grid>
                    <Grid item>
                      <Typography variant="body2" style={{padding:'5px'}}>Werewolves: {props.state.game.roster.filter((player)=>player.isActive==true).filter((player)=>player.isWerewolf==true).length}</Typography>
                    </Grid>
                  </Grid>
              </Grid>
            </Grid>
          </Container>
        </Paper>
      </Grid>
      <Grid item>
        <VillagerOverview style={{height:'100%', padding:'5px'}} roster={props.state.game.roster}/>
      </Grid>
    {/* Roster Breakdown End */}

      {props.state.game.location.isNight && props.state.role.isAsleepAtNight?
       '' :
      <Grid item xs={12} style={{padding:'5px', marginBottom:'30px'}}>
        <PollPage style={{padding:'15px'}} results={props.state.results} />
      </Grid>}
    </Grid>

    <RolePopup  
      open={state.showRolePopUp}
      onClose={toggleRolePopup}
      role={props.state.role}
    />  

    <VotePopup  
      open={state.showVotePopUp}
      onClose={toggleVotePopup}
      ballot={props.state.role.ballot}
      onVote={submitVote}
    />  

    <DeactivatedPopup  
      open={state.showDeactivatedPopup}
      onClose={toggleDeactivatedPopup}
      player={deactivatedPlayer}
    />  

    <Grid container spacing={2} justify='flex-end' alignItems='flex-end' style={{position: 'fixed', bottom: '7px'}}>
      <Grid item>
        {props.state.role.name === 'Narrator'?
          <Fab variant="extended" onClick={submitTimeOfDayChange}>{props.state.game.location.isNight?<div><Brightness7Icon/>Wake Up</div>:<div><Brightness3Icon />Go To Sleep</div>}</Fab>
          :<Fab variant="extended" onClick={toggleVotePopup} disabled={props.state.role.ballot?props.state.role.ballot.length <= 0:true}><div><HowToVoteIcon/> Vote</div></Fab>
          }   
      </Grid>
      <Grid item>
        <Fab variant="extended" onClick={toggleRolePopup} ><div><PersonIcon/> Role</div></Fab>    
      </Grid>
    </Grid>
  </div>
)};

Playroom.propTypes = {
};

Playroom.defaultProps = {};

export default Playroom;
