import React from 'react';
import PropTypes from 'prop-types';
import styles from './deactivatedPopup.module.css';
import {Box, Dialog, DialogTitle, DialogContentText} from '@material-ui/core';

const DeactivatedPopup = (props) => (
  <Dialog
    className={styles.deactivatedPopup} data-testid="deactivatedPopup"
    open={props.open}
    onClose={props.onClose}
  >
    <Box className='popup\_inner'>  
      {props.player?
      <DialogTitle> {props.player.name} was killed  </DialogTitle>:
      <DialogTitle>Everyone Survived</DialogTitle>} 
     
      {props.player?
        <DialogContentText 
          style={{padding:"15px"}}>
          {props.player.name} was a {props.player.isWerewolf? 'werewolf' : 'villager'}
        </DialogContentText>
      :''}
    </Box>  
</Dialog>
);

DeactivatedPopup.propTypes = {};

DeactivatedPopup.defaultProps = {
  player:{
    name:'',
    isWerewolf:false,
  }
};

export default DeactivatedPopup;
