import React, { useState }  from 'react';
import PropTypes from 'prop-types';
import styles from './playroom.module.css';
import NightPlayroom from '../nightPlayroom/nightPlayroom';
import DayPlayroom from '../dayPlayroom/dayPlayroom';
import RolePopup from '../rolePopup/rolePopup';
import VotePopup from '../votePopup/votePopup';

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
    {state.showRolePopUp ?  
      <RolePopup  
                role={props.state.role}
      />  
      : ""
    } 
    {state.showVotePopUp ?  
      <VotePopup  
                ballot={props.state.role.ballot}
      />  
      : ""
    } 
    <button onClick={toggleRolePopup} >{state.showRolePopUp ?  "X" : "Role"}</button>    
    <button onClick={toggleVotePopup} >{state.showVotePopUp ?  "X": "Vote"}</button>    
  </div>
)};

Playroom.propTypes = {};

Playroom.defaultProps = {};

export default Playroom;
