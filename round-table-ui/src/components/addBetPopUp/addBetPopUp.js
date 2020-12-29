import React from 'react';
import PropTypes from 'prop-types';
import styles from './addBetPopUp.module.css';
import { Box, Dialog, DialogTitle } from '@material-ui/core';
import OptionList from '../optionList/optionList';

const AddBetPopUp = (props) => {
  return (
    <Dialog className={styles.rolePopup} data-testid="addBetsPopup"
      open={props.open}
      onClose={props.onClose}
    >
      <Box className='popup\_inner'>  
        <DialogTitle>
          Add Bet
        </DialogTitle>
        <OptionList gameId={props.gameId} options={props.options} />
      </Box>  
    </Dialog>
)};

AddBetPopUp.propTypes = {};

AddBetPopUp.defaultProps = {};

export default AddBetPopUp;
