import React, { useState }  from 'react';
import { useHistory } from "react-router-dom";
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
import { Typography, Grid, Paper, Container, Button } from '@material-ui/core';
import Brightness3Icon from '@material-ui/icons/Brightness3';
import Brightness7Icon from '@material-ui/icons/Brightness7';
import PersonAddIcon from '@material-ui/icons/PersonAdd';
import LocalLibraryIcon from '@material-ui/icons/LocalLibrary';
import * as R from 'ramda';


const Playroom = (props) => {
  const history = useHistory();
  const [state, setState] = useState({showRolePopUp:!R.isEmpty(props.state.role), showVotePopUp:false, showDeactivatedPopup:false});
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
          <Container style={{height:'100%', paddingLeft:'24px', paddingRight:'24px'}}>
            <Grid container
              alignItems="center"
              justify="center"
              style={{height:'100%'}}>
              <Grid item>
                <Grid container spacing={2} 
                  direction="column"
                  alignItems="center"
                  justify="stretch"
                  >
                  <Grid item>
                    <Typography variant="h5">Narrator:</Typography>
                  </Grid>
                  <Grid item>
                    <Player isNarrator={true} name={props.state.game.roster.find((player)=>player.isNarrator).name} />
                  </Grid>
                  <Grid item>
                    <Typography variant='body2'>Roomcode: {props.state.game.id}</Typography>
                  </Grid>
                </Grid> 
              </Grid>
            </Grid>

          </Container>
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

    <Grid container spacing={2} direction='row-reverse' justify='space-between' alignItems='flex-end' style={{position: 'fixed', bottom: '7px'}}>
      {R.isEmpty(props.state.role)?
        <Grid item>
          <Fab variant="extended" onClick={()=>{
            history.push('/register?game='+ props.state.game.id)
          }} ><><PersonAddIcon/> Register</></Fab>    
        </Grid>:
          <>
            <Grid item>
              <Fab variant="extended" onClick={toggleRolePopup} ><>{props.state.role.player.isNarrator?<LocalLibraryIcon/>:<PersonIcon />}{props.state.role.player.name}</></Fab>    
            </Grid>
            <Grid item>
              {props.state.role.name === 'Narrator'?
                <Fab variant="extended" onClick={submitTimeOfDayChange}>{props.state.game.location.isNight?<><Brightness7Icon/>Wake Up</>:<><Brightness3Icon />Go To Sleep</>}</Fab>
                :<Fab variant="extended" onClick={toggleVotePopup} disabled={props.state.role.ballot?props.state.role.ballot.length <= 0:true}><><HowToVoteIcon/>Vote</></Fab>
                }   
            </Grid>
          </>  
      }
    </Grid>
  </div>
)};

Playroom.propTypes = {
};

Playroom.defaultProps = {};

export default Playroom;
