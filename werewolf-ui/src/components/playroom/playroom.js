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
import Modal from '@material-ui/core/Modal';

const Playroom = (props) => {
  //TODO updates to props.state do not propagate
  const [state, setState] = useState({showRolePopUp:false, showVotePopUp:false});

  function toggleRolePopup() {  
    setState({
      showRolePopUp: !state.showRolePopUp, 
      showVotePopUp: false 
    });  
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
    {props.state.game.location.isNight? 
      <NightPlayroom state={props.state}></NightPlayroom> :
      <DayPlayroom  state={props.state}></DayPlayroom>
    }

    <RolePopup  
      open={state.showRolePopUp}
      onClose={toggleRolePopup}
      role={props.state.role}
    />  

    {state.showVotePopUp ?  
      <VotePopup  
                ballot={props.state.role.ballot}
      />  
      : ""
    } 
    <Fab variant="extended" onClick={toggleVotePopup} ><div><HowToVoteIcon/> Vote</div></Fab>    

    <Box style={{position: 'fixed', bottom: '7px', right:'7px'}} >
      <Fab variant="extended" onClick={toggleRolePopup} ><div><PersonIcon/> Role</div></Fab>    
    </Box>
  </div>
)};

Playroom.propTypes = {};

Playroom.defaultProps = {};

export default Playroom;
