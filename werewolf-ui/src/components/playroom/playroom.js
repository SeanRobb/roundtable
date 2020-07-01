import React, { useState }  from 'react';
import PropTypes from 'prop-types';
import styles from './playroom.module.css';
import NightPlayroom from '../nightPlayroom/nightPlayroom';
import DayPlayroom from '../dayPlayroom/dayPlayroom';
import RolePopup from '../rolePopup/rolePopup';
import VotePopup from '../votePopup/votePopup';
import Fab from '@material-ui/core/Fab';  
import HowToVoteIcon from '@material-ui/icons/HowToVote';
import PersonIcon from '@material-ui/icons/Person';
import Box from '@material-ui/core/Box';
import {vote} from '../../utils/index';
import { List, ListItem, Typography } from '@material-ui/core';

const Playroom = (props) => {
  //TODO updates to props.state do not propagate
  const [state, setState] = useState({showRolePopUp:false, showVotePopUp:false});

  function toggleRolePopup() {  
    setState({
      showRolePopUp: !state.showRolePopUp, 
      showVotePopUp: false 
    });  
  };  

  function submitVote(player) {  
    setState({
      showRolePopUp: false, 
      showVotePopUp: false 
    });  
    vote(props.state.game.id, player);
  }; 

  function toggleVotePopup() {  
    setState({
      showRolePopUp: false, 
      showVotePopUp: !state.showVotePopUp 
    });  
  }; 

  return (
  <div className={styles.Playroom} data-testid="Playroom">
    <div>
      Active: {props.state.role.isActive ? "Yes" : "No"}
    </div>

    <List>
      {Object.entries(props.state.results.votes).map((entries) => {
        return (
        <ListItem key={entries[0]}>
          <Typography variant="body1">{entries[0]}:</Typography>
           {entries[1].map((person)=> <PersonIcon key={person}/>)}
        </ListItem> 
        );
      })}

    </List>

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

    <Box style={{position: 'fixed', bottom: '7px', right:'7px'}} >
      <Fab variant="extended" onClick={toggleVotePopup} disabled={props.state.role.ballot.length <= 0}><div><HowToVoteIcon/> Vote</div></Fab>    
      <Fab variant="extended" onClick={toggleRolePopup} ><div><PersonIcon/> Role</div></Fab>    
    </Box>
  </div>
)};

Playroom.propTypes = {};

Playroom.defaultProps = {};

export default Playroom;
